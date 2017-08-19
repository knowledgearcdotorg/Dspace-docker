#!/bin/bash

# Usage: archive [options] NAME DOMAIN EMAIL REGION AWS_ADMIN_ACCESS_KEY_ID AWS_ADMIN_SECRET_ACCESS_KEY
# [options]
# --deploy-https    Do not build archive with https support.

DEPLOY_HTTPS=0

while test $# -gt 0; do
    case "$1" in
        --deploy-https)
            DEPLOY_HTTPS=1
            ;;
        *)
            NAME=$1
            shift

            DOMAIN=$1
            shift

            EMAIL=$1
            shift

            REGION=$1 # The aws region not the elastic hosts region.
            shift

            AWS_ADMIN_ACCESS_KEY_ID=$1
            shift

            AWS_ADMIN_SECRET_ACCESS_KEY=$1
            ;;
    esac

    shift
done

export DSPACE_VERSION="5.5"

export ARCHIVE_DOMAIN="archive.$DOMAIN"
export AWS_S3_ARCHIVE_BUCKET="archive.$NAME.knowledgearc.net"
export AWS_S3_BACKUP_BUCKET="backup.$NAME.knowledgearc.net"

TRANSPORT_PROTOCOL="http"
if [$DEPLOY_HTTPS = 1]; then
    TRANSPORT_PROTOCOL="https"
fi

export GIT_TOKEN="8c0dfa695040f0191da14f55b95a19bf24ac9a7f" # need to pass this in. Currently a security issue as it gets committed to github.
CONFIG_TEMPLATE_PATH=/tmp/platform-images-archive

# generate mysql root password prior to installation.
MYSQLROOTPWD=`date +%s | sha256sum | base64 | head -c 32 ; echo`

echo "mysql_root_password=$MYSQLROOTPWD" >> /etc/knowledgearc/config

# suppress mysql-server password prompt.
debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQLROOTPWD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQLROOTPWD"

aptitude install -y default-jdk tomcat7 postgresql mysql-server mysql-client apache2 php5 php5-mysql php5-curl php5-pgsql git subversion maven lynx awscli

# Get archive configuration from images directory
svn export --no-auth-cache --password $GIT_TOKEN https://github.com/knowledgearc/platform/trunk/images/archive $CONFIG_TEMPLATE_PATH

# update ulimit entry for Apache2
echo "APACHE_ULIMIT_MAX_FILES=true" >> /etc/apache2/envvars

# update and enable ssl support
sed -i \
-e '/SSLCipherSuite HIGH:MEDIUM:!aNULL:!MD5/s/\t/\t#/' \
-e 's/#SSLCipherSuite RC4-SHA:AES128-SHA:HIGH:MEDIUM:!aNULL:!MD5/SSLCipherSuite ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4/' \
-e '/SSLHonorCipherOrder on/s/^\t#/\t/' \
-e '/SSLProtocol/s/all/TLSv1 TLSv1.1 TLSv1.2 -SSLv2 -SSLv3/' /etc/apache2/mods-available/ssl.conf

a2enmod ssl proxy_ajp proxy

service apache2 restart

# Fix known issue: https://bugs.launchpad.net/ubuntu/+source/tomcat7/+bug/1232258
cd /usr/share/tomcat7
ln -s /var/lib/tomcat7/common/ common
ln -s /var/lib/tomcat7/server/ server
ln -s /var/lib/tomcat7/shared/ shared

# Update /etc/default/tomcat7's memory settings.
sed -i 's/^JAVA_OPTS=.*/JAVA_OPTS="-Djava.awt.headless=true -Xms256M -Xmx1G -XX:+UseConcMarkSweepGC"/' /etc/default/tomcat7

# add AWS to env variables
export AWS_CONFIG_FILE=/etc/aws/config
echo "AWS_CONFIG_FILE=$AWS_CONFIG_FILE" >> /etc/environment

# configure aws cli tools. Configure with temporary settings via env vars.
export AWS_ACCESS_KEY_ID=$AWS_ADMIN_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_ADMIN_SECRET_ACCESS_KEY

# create IAM user for account
aws iam create-user --user-name $NAME --output text

OUT=`aws iam create-access-key --user-name $NAME --output text` # save access id and key to /etc/aws/config
AWS_USER_ACCESS_KEY_ID="`echo "$OUT" | cut -f2`"
AWS_USER_SECRET_ACCESS_KEY="`echo "$OUT" | cut -f4`"

aws iam add-user-to-group --user-name $NAME --group-name customers
aws iam add-user-to-group --user-name $NAME --group-name archives

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

# reconfigure aws cli tools with new IAM details and s3 bucket
# aws configure
# unset AWS admin settings
export AWS_ACCESS_KEY_ID=$AWS_USER_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_USER_SECRET_ACCESS_KEY

mkdir -p /etc/aws
echo "[default]
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
aws_access_key_id = $AWS_ACCESS_KEY_ID
output = json" > /etc/aws/config

# Install Akeeba Backup Solo and configure to back up DSpace

# Generate password for DSpace
DSPACEPWD=`date +%s | sha256sum | base64 | head -c 32 ; echo`

su - postgres -c "psql -c \"CREATE USER \\\"dspace\\\" PASSWORD '$DSPACEPWD';\""
su - postgres -c "psql -c \"CREATE DATABASE \\\"dspace\\\" OWNER \\\"dspace\\\" ENCODING 'UTF8' TEMPLATE template0;\""

# Install SSL certs (create even if sites should use http)
openssl req -nodes -new -newkey rsa:2048 -nodes -keyout /etc/ssl/private/$NAME.key -out /etc/ssl/private/$NAME.csr -subj "/C=GB/ST=East Sussex/L=Brighton & Hove/O=KnowledgeArc Ltd/OU=knowledgearc.net/CN=$DOMAIN/emailAddress=webmaster@knowledgearc.com"

if [ $DEPLOY_HTTPS = 1 ]; then
    # key/csr need to be backed up.

    # Apply with cert authority (namecheap.com)
    # Once delivered, install crt and ca-bundle to:
    #/etc/ssl/certs/$NAME.crt
    #/etc/ssl/certs/$NAME.ca-bundle
fi

mkdir /opt/dspace

# download customized dspace from github.
# enable Mirage 2
aptitude install npm nodejs-legacy ruby ruby-sass ruby-compass -y
npm install -g bower && npm install -g grunt # && npm install -g grunt-cli (this does not appear to be needed to get mirage2 to compile)

su tomcat7 -s /bin/bash
export HOME=/opt/dspace
export GEM_HOME=$HOME/.gem/
export GEM_PATH=$GEM_HOME

cd /tmp/
curl -O -J -L -u $GIT_TOKEN:x-oauth-basic https://github.com/knowledgearc/dspace-hosted/archive/dspace-$DSPACE_VERSION.zip
unzip /tmp/dspace-hosted-dspace-$DSPACE_VERSION.zip
cd /tmp/dspace-hosted-dspace-$DSPACE_VERSION

# create ses password from iam secret.
MSG="SendRawEmail";
VerInBytes="2";
VerInBytes=$(printf \\$(printf '%03o' "$VerInBytes"));

SignInBytes=$(echo -n "$MSG"|openssl dgst -sha256 -hmac "$AWS_SECRET_ACCESS_KEY" -binary);
SignAndVer=""$VerInBytes""$SignInBytes"";
AWS_SES_PASSWORD=$(echo -n "$SignAndVer"|base64);

# replace build properties with valid values
# NOTE: default to if/until handle.net is configured
sed -i \
-e 's/^dspace\.hostname\s*=\s*.*/dspace\.hostname='$ARCHIVE_DOMAIN'/' \
-e 's/^dspace\.baseUrl\s*=\s*.*/dspace\.baseUrl='$TRANSPORT_PROTOCOL'\:\/\/'$ARCHIVE_DOMAIN'/' \
-e 's/^dspace\.name\s*=\s*.*/dspace\.name='$NAME'/' \
-e 's/^db\.url\s*=\s*.*/db\.url=jdbc:postgresql\:\/\/localhost\:5432\/dspace/' \
-e 's/^db\.username\s*=\s*.*/db\.username=dspace/' \
-e 's/^db\.password\s*=\s*.*/db\.password='$DSPACEPWD'/' \
-e 's/^handle\.canonical\.prefix\s*=\s*.*/handle\.canonical\.prefix='$TRANSPORT_PROTOCOL'\:\/\/'$ARCHIVE_DOMAIN'\/handle/' \
-e 's/^mail\.server\.username\s*=\s*.*/mail\.server\.username='$AWS_ACCESS_KEY_ID'/' \
-e 's/^mail\.server\.password\s*=\s*.*/mail\.server\.password='$(echo $AWS_SES_PASSWORD | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')'/' \
-e 's/^mail\.from\.address\s*=\s*.*/mail\.from\.address='$EMAIL'/' \
-e 's/^mail\.feedback\.recipient\s*=\s*.*/mail\.feedback\.recipient='$EMAIL'/' \
-e 's/^mail\.admin\s*=\s*.*/mail\.admin='$EMAIL'/' \
-e 's/^mail\.alert\.recipient\s*=\s*.*/mail\.alert\.recipient='$EMAIL'/' \
-e 's/^mail\.registration\.notify\s*=\s*.*/mail\.registration\.notify='$EMAIL'/' \
-e 's/^s3\.bucket\.size\s*=\s*.*/s3\.bucket\.size='$S3BUCKETSIZE'/' \
-e 's/^s3\.bucket\s*=\s*.*/s3\.bucket='$AWS_S3_ARCHIVE_BUCKET'/' \
-e 's/^s3\.secret_key_id\s*=\s*.*/s3\.secret_key_id='$AWS_ACCESS_KEY_ID'/' \
-e 's/^s3\.secret_key_access\s*=\s*.*/s3\.secret_key_access='$(echo $AWS_SECRET_ACCESS_KEY | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')'/' /tmp/dspace-hosted-dspace-$DSPACE_VERSION/build.properties

export MAVEN_OPTS="-Xmx2G" && mvn -U clean package -Dmirage2.on=true -Dmirage2.deps.included=false -Dmaven.repo.local=$HOME/.maven
ant fresh_install -buildfile /tmp/dspace-hosted-dspace-$DSPACE_VERSION/dspace/target/dspace-installer/build.xml

sed -i 's/^identifier\.prefix\s*=\s*.*/identifier\.prefix=$DOMAIN/' /opt/dspace/config/modules/oai.cfg

## not sure if this is needed but keeping for reference.
#cp /opt/dspace/lib/postgresql-9.1-901-1.jdbc4.jar /usr/share/tomcat7/lib/
#find /opt/dspace/ -name 'postgresql-9.1-901-1.jdbc4.jar' -exec rm -rf {} \;
#find /opt/dspace/ -name 'servlet-api-2.5-20081211.jar' -exec rm -rf {} \;

mkdir /etc/tomcat7/Catalina/archive.$NAME.knowledgearc.net

echo '<?xml version="1.0" ?>
<Context name="" docBase="/opt/dspace/webapps/xmlui" reloadable="true" crossContext="true">
    <WatchedResource>WEB-INF/web.xml</WatchedResource>
</Context>' > /etc/tomcat7/Catalina/archive.$NAME.knowledgearc.net/ROOT.xml

echo '<?xml version="1.0" ?>
<Context name="/rest" docBase="/opt/dspace/webapps/rest" reloadable="true" crossContext="true">
    <WatchedResource>WEB-INF/web.xml</WatchedResource>
</Context>' > /etc/tomcat7/Catalina/archive.$NAME.knowledgearc.net/rest.xml

echo '<?xml version="1.0" ?>
<Context name="/oai" docBase="/opt/dspace/webapps/oai" reloadable="true" crossContext="true">
    <WatchedResource>WEB-INF/web.xml</WatchedResource>
</Context>' > /etc/tomcat7/Catalina/archive.$NAME.knowledgearc.net/oai.xml

echo '<?xml version="1.0" ?>
<Context name="/solr" docBase="/opt/dspace/webapps/solr" reloadable="true" crossContext="true">
    <WatchedResource>WEB-INF/web.xml</WatchedResource>
</Context>' > /etc/tomcat7/Catalina/localhost/solr.xml

chgrp -R tomcat7 /etc/tomcat7/Catalina/*

# set up xslt files for manipulating Tomcat settings via bash.
echo "<xsl:stylesheet version=\"1.0\" xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\">
    <xsl:template match=\"node() | @*\">
        <xsl:copy>
            <xsl:apply-templates select=\"node() | @*\" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match=\"comment()[contains(., 'Connector') and contains(., 'port=&quot;8009&quot;')]\">
        <xsl:value-of select=\".\" disable-output-escaping=\"yes\" />
    </xsl:template>
</xsl:stylesheet>" > /tmp/enable-ajp.xsl

echo "<xsl:stylesheet xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\" version=\"1.0\">
    <xsl:output method=\"xml\" indent=\"yes\"/>

    <xsl:template match=\"Engine\">
        <xsl:copy>
            <xsl:apply-templates select=\"@*\"/>
            <xsl:apply-templates select=\"node()\"/>
            <xsl:text>  </xsl:text>
            <Host
                name=\"archive.$DOMAIN\"
                xmlBase=\"/etc/tomcat7/Catalina/archive.$NAME.knowledgearc.net\"
                startStopThreads=\"200\"
                autoDeploy=\"false\"></Host>
        <xsl:text>&#10;    </xsl:text>
        </xsl:copy>
    </xsl:template>

    <xsl:template match=\"@*|node()\">
        <xsl:copy>
            <xsl:apply-templates select=\"@*|node()\" />
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>" > /tmp/enable-host.xsl

aptitude install -y xsltproc

# enable ajp
xsltproc /tmp/enable-ajp.xsl /etc/tomcat7/server.xml > /etc/tomcat7/server-enable-ajp.xml

# enable remote host "archive.$DOMAIN"
xsltproc /tmp/enable-host.xsl /etc/tomcat7/server-enable-ajp.xml > /etc/tomcat7/server-enable-host.xml

rm /etc/tomcat7/server-enable-ajp.xml

mv /etc/tomcat7/server-enable-host.xml /etc/tomcat7/server.xml

rm /tmp/enable-*.xsl

# xsltproc can probably be installed as part of all knowledgearc containers but for now we will remove to keep installed pacakges low.
aptitude remove -y xsltproc

service tomcat7 restart

su - tomcat7 -s /bin/bash -c '/opt/dspace/bin/dspace index-discovery'
su - tomcat7 -s /bin/bash -c '/opt/dspace/bin/dspace oai import -c'

# Configure Apache2 archive-ssl.conf
if [ $DEPLOY_HTTPS = 1 ]; then
    cp $CONFIG_TEMPLATE_PATH/etc/apache2/sites-available/archive-ssl.conf /etc/apache2/sites-available/

    sed -i \
    -e 's/{domain}/archive\.'$DOMAIN'/g' \
    -e 's/{unique-name}/'$NAME'/g' /etc/apache2/sites-available/archive-ssl.conf

    a2ensite archive-ssl
else
    cp $CONFIG_TEMPLATE_PATH/etc/apache2/sites-available/archive.conf /etc/apache2/sites-available/

    sed -i 's/{domain}/archive\.$DOMAIN/g' /etc/apache2/sites-available/archive.conf

    a2ensite archive
fi

apache2ctl graceful

# Set up cron job for dspace
cp $CONFIG_TEMPLATE_PATH/etc/cron.d/dspace /etc/cron.d/
service cron restart

rm -Rf $CONFIG_TEMPLATE_PATH