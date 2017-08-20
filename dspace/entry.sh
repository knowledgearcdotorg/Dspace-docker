#!/bin/bash

cd /opt/dspace-6.1-src-release/dspace/target/dspace-installer

check=1

while [ ! $check -eq 0 ]
do
    pg_isready -h postgres -p5432
    check=$?
done

echo "Password is:"$PGPASSWORD
psql -h postgres -p 5432 --username=dspace dspace -c "CREATE EXTENSION pgcrypto;"

ant fresh_install

echo '<?xml version="1.0" ?>
<Context name="" docBase="/opt/dspace/webapps/xmlui" reloadable="true" crossContext="true">
    <WatchedResource>WEB-INF/web.xml</WatchedResource>
</Context>' > /opt/apache-tomcat-9.0.0.M26/conf/Catalina/ROOT.xml

echo '<?xml version="1.0" ?>
<Context name="/rest" docBase="/opt/dspace/webapps/rest" reloadable="true" crossContext="true">
    <WatchedResource>WEB-INF/web.xml</WatchedResource>
</Context>' > /opt/apache-tomcat-9.0.0.M26/conf/Catalina/rest.xml

echo '<?xml version="1.0" ?>
<Context name="/oai" docBase="/opt/dspace/webapps/oai" reloadable="true" crossContext="true">
    <WatchedResource>WEB-INF/web.xml</WatchedResource>
</Context>' > /opt/apache-tomcat-9.0.0.M26/conf/Catalina/oai.xml

echo '<?xml version="1.0" ?>
<Context name="/solr" docBase="/opt/dspace/webapps/solr" reloadable="true" crossContext="true">
    <WatchedResource>WEB-INF/web.xml</WatchedResource>
</Context>' > /opt/apache-tomcat-9.0.0.M26/conf/Catalina/solr.xml

#echo "Copying webapps to tomcat..."
#cp -r /opt/dspace/webapps/xmlui /opt/dspace/webapps/oai /opt/dspace/webapps/solr /opt/dspace/webapps/rest /opt/apache-tomcat-9.0.0.M26/webapps
#echo "Completed copying webapps."

/opt/apache-tomcat-9.0.0.M26/bin/catalina.sh run