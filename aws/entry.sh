#!/bin/bash

if [ -z "$NAME" ]; then
    echo "Environment variable NAME is not set!!!"
    exit 1

if [ -z "$EMAIL" ]; then
    echo "Environment variable EMAIL is not set!!!"
    exit 1

if [ -z "$REGION" ]; then
    echo "Environment variable REGION is not set!!!"
    exit 1

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    echo "Environment variable AWS_ACCESS_KEY_ID is not set!!!"
    exit 1

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "Environment variable AWS_SECRET_ACCESS_KEY is not set!!!"
    exit 1

export AWS_S3_ARCHIVE_BUCKET="archive.$NAME.knowledgearc.net"
export AWS_S3_BACKUP_BUCKET="backup.$NAME.knowledgearc.net"

aws iam create-user --user-name $NAME --output text

OUT=`aws iam create-access-key --user-name $NAME --output text` # save access id and key to /etc/aws/config
AWS_USER_ACCESS_KEY_ID="`echo "$OUT" | cut -f2`"
AWS_USER_SECRET_ACCESS_KEY="`echo "$OUT" | cut -f4`"

# Set up AWS SES for account
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
aws s3api create-bucket --bucket $AWS_S3_ARCHIVE_BUCKET --create-bucket-configuration LocationConstraint=$REGION
aws s3api create-bucket --bucket $AWS_S3_BACKUP_BUCKET --create-bucket-configuration LocationConstraint=$REGION

echo "aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
aws_access_key_id = $AWS_ACCESS_KEY_ID" > /config/config