#!/bin/bash

if [ -z "$DIR" ]; then
    echo "Environment variable DIR is not set!!!"
    exit 1
else
    sed -i "s|dspace.dir.*=.*|dspace.dir=${DIR}|1" /opt/dspace-6.1-src-release/dspace/config/dspace.cfg
fi

if [ -z "$HOSTNAME" ]; then
    echo "Environment variable HOSTNAME is not set!!!"
    exit 1
else
    sed -i "s|dspace.hostname.*=.*|dspace.hostname=${HOSTNAME}|1" /opt/dspace-6.1-src-release/dspace/config/dspace.cfg
fi

if [ -z "$DB_URL" ]; then
    echo "Environment variable DB_URL is not set!!!"
    exit 1
else
    sed -i "s|db.url.*=.*|db.url=${DB_URL}|1" /opt/dspace-6.1-src-release/dspace/config/dspace.cfg
fi

if [ -z "$DB_USERNAME" ]; then
    echo "Environment variable DB_USERNAME is not set!!!"
    exit 1
else
    sed -i "s|db.username.*=.*|db.username=${DB_USERNAME}|1" /opt/dspace-6.1-src-release/dspace/config/dspace.cfg
fi

if [ -z "$DB_PASSWORD" ]; then
    echo "Environment variable DB_PASSWORD is not set!!!"
    exit 1
else
    sed -i "s|db.password.*=.*|db.password=${DB_PASSWORD}|1" /opt/dspace-6.1-src-release/dspace/config/dspace.cfg
fi

cd /opt/dspace-6.1-src-release/dspace/target/dspace-installer

check=1

while [ ! $check -eq 0 ]
do
    pg_isready -h postgres -p5432
    check=$?
done

echo "Password is:"$PGPASSWORD
psql -h postgres -p 5432 --username=${DB_USERNAME} dspace -c "CREATE EXTENSION pgcrypto;"

ant fresh_install

echo "I am "$(whoami)

mkdir -p /opt/apache-tomcat-8.0.46/conf/Catalina/dspacehost

echo '<?xml version="1.0" ?>
<Context name="" docBase="/dspace/webapps/xmlui" reloadable="true" crossContext="true">
    <WatchedResource>WEB-INF/web.xml</WatchedResource>
</Context>' > /opt/apache-tomcat-8.0.46/conf/Catalina/dspacehost/ROOT.xml

echo '<?xml version="1.0" ?>
<Context name="/rest" docBase="/dspace/webapps/rest" reloadable="true" crossContext="true">
    <WatchedResource>WEB-INF/web.xml</WatchedResource>
</Context>' > /opt/apache-tomcat-8.0.46/conf/Catalina/rest.xml

echo '<?xml version="1.0" ?>
<Context name="/oai" docBase="/dspace/webapps/oai" reloadable="true" crossContext="true">
    <WatchedResource>WEB-INF/web.xml</WatchedResource>
</Context>' > /opt/apache-tomcat-8.0.46/conf/Catalina/oai.xml

echo '<?xml version="1.0" ?>
<Context name="/solr" docBase="/dspace/webapps/solr" reloadable="true" crossContext="true">
    <WatchedResource>WEB-INF/web.xml</WatchedResource>
</Context>' > /opt/apache-tomcat-8.0.46/conf/Catalina/solr.xml

#echo "Copying webapps to tomcat..."
#cp -r /dspace/webapps/xmlui /dspace/webapps/oai /dspace/webapps/solr /dspace/webapps/rest /opt/apache-tomcat-8.0.46/webapps
#echo "Completed copying webapps."

/opt/apache-tomcat-8.0.46/bin/catalina.sh run