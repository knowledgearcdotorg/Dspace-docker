#!/bin/bash

if [ -z "$NAME" ]; then
    echo "Environment variable NAME is not set!!!"
    exit 1
fi
if [ -z "$EMAIL" ]; then
    echo "Environment variable EMAIL is not set!!!"
    exit 1
fi
if [ -z "$REGION" ]; then
    echo "Environment variable REGION is not set!!!"
    exit 1
fi
if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    echo "Environment variable AWS_ACCESS_KEY_ID is not set!!!"
    exit 1
else
    AWS_ACCESS_KEY_ID=`echo $AWS_ACCESS_KEY_ID | tr -d '\n'`
fi
if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "Environment variable AWS_SECRET_ACCESS_KEY is not set!!!"
    exit 1
else
    AWS_SECRET_ACCESS_KEY=`echo $AWS_SECRET_ACCESS_KEY | tr -d '\n'`
fi

namespace=$NAME;
service="dspace";
cacert="/var/run/secrets/kubernetes.io/serviceaccount/ca.crt";
token="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)";
export service=$(curl -s --cacert $cacert --header "Authorization:Bearer $token" https://kubernetes.default.svc/api/v1/namespaces/$namespace/services/$service | jq -r '.status.loadBalancer.ingress[0].hostname');

echo "Service:" $service

cat /config/config

echo "File contents above."
# Route53
# Check if Record exists
record=`aws route53 list-resource-record-sets --hosted-zone-id $ZONE_ID | jq --arg name "$NAME.archive.knowledgearc.net." '.ResourceRecordSets[] | select(.Name==$name) | length'`

if [ -z $record ];
then
echo "No record exists. Creating record..."
echo '{ "Comment": "Record automatically created by aws-bootstrap.",
        "Changes": [
            {
                "Action": "CREATE",
                "ResourceRecordSet": {
                    "Name": "${NAME}.archive.knowledgearc.net",
                    "Type": "CNAME",
                    "TTL": 600,
                  "ResourceRecords": [
                    {
                      "Value": "${service}"
                    }
                  ]
                }
            }
        ]
}' | envsubst > /tmp/route53.json
cat /tmp/route53.json
aws route53 change-resource-record-sets --hosted-zone-id $ZONE_ID --change-batch file:///tmp/route53.json
else
echo "Record exists. Updating..."
echo '{ "Comment": "Record automatically created by aws-bootstrap.",
        "Changes": [
            {
                "Action": "UPSERT",
                "ResourceRecordSet": {
                    "Name": "${NAME}.archive.knowledgearc.net",
                    "Type": "CNAME",
                    "TTL": 600,
                  "ResourceRecords": [
                    {
                      "Value": "${service}"
                    }
                  ]
                }
            }
        ]
}' | envsubst > /tmp/route53.json
cat /tmp/route53.json
aws route53 change-resource-record-sets --hosted-zone-id $ZONE_ID --change-batch file:///tmp/route53.json
fi

export AWS_S3_ARCHIVE_BUCKET="archive.$NAME.knowledgearc.net"
export AWS_S3_BACKUP_BUCKET="backup.$NAME.knowledgearc.net"

keys=`aws iam list-access-keys --user-name $NAME`
number=`echo $keys | jq '.AccessKeyMetadata | length'`
if [ $number -gt 0 ]; 
then
    aws iam delete-access-key --access-key $(echo $keys | jq -r '.AccessKeyMetadata[0].AccessKeyId') --user-name $NAME; 
fi

aws iam create-user --user-name $NAME --output text

OUT=`aws iam create-access-key --user-name $NAME --output text` # save access id and key to /etc/aws/config
AWS_USER_ACCESS_KEY_ID="`echo "$OUT" | cut -f2`"
AWS_USER_SECRET_ACCESS_KEY="`echo "$OUT" | cut -f4`"

# Adding user to group
aws iam add-user-to-group --user-name $NAME --group-name customers
aws iam add-user-to-group --user-name $NAME --group-name archives

# Set up AWS SES for account
if [ -z "$EMAIL" ]; then
    export EMAIL="webmaster@knowledgearc.com"
fi

aws ses verify-email-identity --email-address $EMAIL --endpoint-url https://email.$REGION.amazonaws.com --region $REGION
echo '{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ses:SendEmail",
                "ses:SendRawEmail"
            ],
            "Resource": "*"
        }
    ]
}' > /tmp/ses-policy.json
aws iam put-user-policy --user-name $NAME --policy-name ses --policy-document file:///tmp/ses-policy.json

rm /tmp/ses-policy.json

# Set up AWS S3 bucket for account
aws s3api create-bucket --bucket $AWS_S3_ARCHIVE_BUCKET  --region $REGION --create-bucket-configuration LocationConstraint=$REGION
aws s3api create-bucket --bucket $AWS_S3_BACKUP_BUCKET  --region $REGION --create-bucket-configuration LocationConstraint=$REGION

echo "export AWS_SECRET_ACCESS_KEY=${AWS_USER_SECRET_ACCESS_KEY}
export AWS_ACCESS_KEY_ID=${AWS_USER_ACCESS_KEY_ID}
export EMAIL=${EMAIL}" >> /config/config
