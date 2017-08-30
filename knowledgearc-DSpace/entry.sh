#!/bin/bash

##########################
# SERVER CONFIGURATION   #
##########################

if [ ! -z "$DSPACE_DIR" ]; then
    sed -i "s|dspace.dir.*=.*|dspace.dir=${DSPACE_DIR}|1" /opt/dspace/dspace/config/local.cfg
fi

if [ ! -z "$DSPACE_HOSTNAME" ]; then
    sed -i "s|dspace.hostname.*=.*|dspace.hostname=${DSPACE_HOSTNAME}|1" /opt/dspace/dspace/config/local.cfg
fi

if [ ! -z "$DSPACE_BASEURL" ]; then
    sed -i "s|dspace.baseUrl.*=.*|dspace.baseUrl=${DSPACE_BASEURL}|1" /opt/dspace/dspace/config/local.cfg
fi

if [ ! -z "$DSPACE_URL" ]; then
    sed -i "s|dspace.url.*=.*|dspace.url=${DSPACE_URL}|1" /opt/dspace/dspace/config/local.cfg
fi

if [ ! -z "$DSPACE_UI" ]; then
    sed -i "s|dspace.ui.*=.*|dspace.ui=${DSPACE_UI}|1" /opt/dspace/dspace/config/local.cfg
fi

if [ ! -z "$DSPACE_NAME" ]; then
    sed -i "s|dspace.name.*=.*|dspace.name=${DSPACE_NAME}|1" /opt/dspace/dspace/config/local.cfg
fi

if [ ! -z "$DEFAULT_LANGUAGE" ]; then
    sed -i "s|default.language.*=.*|default.language=${DEFAULT_LANGUAGE}|1" /opt/dspace/dspace/config/local.cfg
fi

if [ ! -z "$SOLR_SERVER" ]; then
    sed -i "s|solr.server.*=.*|solr.server=${SOLR_SERVER}|1" /opt/dspace/dspace/config/local.cfg
fi

if [ ! -z "$ASSETSTORE_DIR" ]; then
    sed -i "s|assetstore.dir.*=.*|assetstore.dir=${ASSETSTORE_DIR}|1" /opt/dspace/dspace/config/local.cfg
fi

##########################
# DATABASE CONFIGURATION #
##########################

if [ ! -z "$DB_URL" ]; then
    sed -i "s|db.url.*=.*|db.url=${DB_URL}|1" /opt/dspace/dspace/config/local.cfg
fi

if [ ! -z "$DB_USERNAME" ]; then
    sed -i "s|db.username.*=.*|db.username=${DB_USERNAME}|1" /opt/dspace/dspace/config/local.cfg
fi

if [ ! -z "$DB_PASSWORD" ]; then
    sed -i "s|db.password.*=.*|db.password=${DB_PASSWORD}|1" /opt/dspace/dspace/config/local.cfg
fi

if [ ! -z "$DB_DRIVER" ]; then
    sed -i "s|db.driver.*=.*|db.driver=${DB_DRIVER}|1" /opt/dspace/dspace/config/local.cfg
fi

if [ ! -z "$DB_DIALECT" ]; then
    sed -i "s|db.dialect.*=.*|db.dialect=${DB_DIALECT}|1" /opt/dspace/dspace/config/local.cfg
fi

if [ ! -z "$DB_SCHEMA" ]; then
    sed -i "s|db.schema.*=.*|db.schema=${DB_SCHEMA}|1" /opt/dspace/dspace/config/local.cfg
fi

if [ ! -z "$DB_MAXCONNECTIONS" ]; then
    sed -i "s|db.maxconnections.*=.*|db.maxconnections=${DB_MAXCONNECTIONS}|1" /opt/dspace/dspace/config/local.cfg
fi

if [ ! -z "$DB_MAXWAIT" ]; then
    sed -i "s|db.maxwait.*=.*|db.maxwait=${DB_MAXWAIT}|1" /opt/dspace/dspace/config/local.cfg
fi

if [ ! -z "$DB_MAXIDLE" ]; then
    sed -i "s|db.maxidle.*=.*|db.maxidle=${DB_MAXIDLE}|1" /opt/dspace/dspace/config/local.cfg
fi

if [ ! -z "$DB_SCHEMA" ]; then
    sed -i "s|db.schema.*=.*|db.schema=${DB_SCHEMA}|1" /opt/dspace/dspace/config/local.cfg
fi

#######################
# EMAIL CONFIGURATION #
#######################

if [ ! -z "$MAIL_SERVER" ]; then
    sed -i "s|mail.server.*=.*|mail.server=${MAIL_SERVER}|1" /opt/dspace/dspace/config/local.cfg
fi

if [ ! -z "$MAIL_SERVER_USERNAME" ]; then
    sed -i "s|mail.server.username.*=.*|mail.server.username=${MAIL_SERVER_USERNAME}|1" /opt/dspace/dspace/config/local.cfg
fi

if [ ! -z "$MAIL_SERVER_PASSWORD" ]; then
    sed -i "s|mail.server.password.*=.*|mail.server.password=${MAIL_SERVER_PASSWORD}|1" /opt/dspace/dspace/config/local.cfg
fi

if [ ! -z "$MAIL_SERVER_PORT" ]; then
    sed -i "s|mail.server.port.*=.*|mail.server.port=${MAIL_SERVER_PORT}|1" /opt/dspace/dspace/config/local.cfg
fi

if [ ! -z "$MAIL_FROM_ADDRESS" ]; then
    sed -i "s|mail.from.address.*=.*|mail.from.address=${MAIL_FROM_ADDRESS}|1" /opt/dspace/dspace/config/local.cfg
fi

if [ ! -z "$FEEDBACK_RECIPIENT" ]; then
    sed -i "s|feedback.recipient.*=.*|feedback.recipient=${FEEDBACK_RECIPIENT}|1" /opt/dspace/dspace/config/local.cfg
fi

if [ ! -z "$MAIL_ADMIN" ]; then
    sed -i "s|mail.admin.*=.*|mail.admin=${MAIL_ADMIN}|1" /opt/dspace/dspace/config/local.cfg
fi

if [ ! -z "$ALERT_RECIPIENT" ]; then
    sed -i "s|alert.recipient.*=.*|alert.recipient=${ALERT_RECIPIENT}|1" /opt/dspace/dspace/config/local.cfg
fi

if [ ! -z "$REGISTRATION_NOTIFY" ]; then
    sed -i "s|registration.notify.*=.*|registration.notify=${REGISTRATION_NOTIFY}|1" /opt/dspace/dspace/config/local.cfg
fi


########################
# HANDLE CONFIGURATION #
########################

if [ ! -z "$HANDLE_CANONICAL_PREFIX" ]; then
    sed -i "s|handle.canonical.prefix.*=.*|handle.canonical.prefix=${HANDLE_CANONICAL_PREFIX}|1" /opt/dspace/dspace/config/local.cfg
fi

if [ ! -z "$HANDLE_PREFIX" ]; then
    sed -i "s|handle.prefix.*=.*|handle.prefix=${HANDLE_PREFIX}|1" /opt/dspace/dspace/config/local.cfg
fi

#######################
# PROXY CONFIGURATION #
#######################

if [ ! -z "$HTTP_PROXY_HOST" ]; then
    sed -i "s|http.proxy.host.*=.*|http.proxy.host=${HTTP_PROXY_HOST}|1" /opt/dspace/dspace/config/local.cfg
fi

if [ ! -z "$HTTP_PROXY_PORT" ]; then
    sed -i "s|http.proxy.port.*=.*|http.proxy.port=${HTTP_PROXY_PORT}|1" /opt/dspace/dspace/config/local.cfg
fi

##########################
# AUTHENTICATION METHODS #
##########################

if [ ! -z "$PLUGIN_SEQUENCE_ORG_DSPACE_AUTHENTICATE_AUTHENTICATIONMETHOD" ]; then
    sed -i "s|plugin.sequence.org.dspace.authenticate.AuthenticationMethod.*=.*|plugin.sequence.org.dspace.authenticate.AuthenticationMethod=${PLUGIN_SEQUENCE_ORG_DSPACE_AUTHENTICATE_AUTHENTICATIONMETHOD}|1" /opt/dspace/dspace/config/local.cfg
fi


cd /opt/dspace/dspace/target/dspace-installer

check=1

while [ ! $check -eq 0 ]
do
    pg_isready -h ${POSTGRES_HOST} -p${POSTGRES_PORT}
    check=$?
done

echo "Password is:"$PGPASSWORD
psql -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} --username=${DB_USERNAME} dspace -c "CREATE EXTENSION pgcrypto;"

ant -Dconfig=/opt/dspace/dspace/config/local.cfg fresh_install

echo "I am "$(whoami)

mkdir -p /opt/apache-tomcat-${TOMCAT_MINOR}/conf/Catalina/localhost

echo '<?xml version="1.0" ?>
<Context name="" docBase="/dspace/webapps/xmlui" reloadable="true" crossContext="true">
    <WatchedResource>WEB-INF/web.xml</WatchedResource>
</Context>' > /opt/apache-tomcat-${TOMCAT_MINOR}/conf/Catalina/localhost/ROOT.xml

echo '<?xml version="1.0" ?>
<Context name="/rest" docBase="/dspace/webapps/rest" reloadable="true" crossContext="true">
    <WatchedResource>WEB-INF/web.xml</WatchedResource>
</Context>' > /opt/apache-tomcat-${TOMCAT_MINOR}/conf/Catalina/localhost/rest.xml

echo '<?xml version="1.0" ?>
<Context name="/oai" docBase="/dspace/webapps/oai" reloadable="true" crossContext="true">
    <WatchedResource>WEB-INF/web.xml</WatchedResource>
</Context>' > /opt/apache-tomcat-${TOMCAT_MINOR}/conf/Catalina/localhost/oai.xml

echo '<?xml version="1.0" ?>
<Context name="/solr" docBase="/dspace/webapps/solr" reloadable="true" crossContext="true">
    <WatchedResource>WEB-INF/web.xml</WatchedResource>
</Context>' > /opt/apache-tomcat-${TOMCAT_MINOR}/conf/Catalina/localhost/solr.xml

#echo "Copying webapps to tomcat..."
#cp -r /dspace/webapps/xmlui /dspace/webapps/oai /dspace/webapps/solr /dspace/webapps/rest /opt/apache-tomcat-${TOMCAT_MINOR}/webapps
#echo "Completed copying webapps."

/opt/apache-tomcat-${TOMCAT_MINOR}/bin/catalina.sh run