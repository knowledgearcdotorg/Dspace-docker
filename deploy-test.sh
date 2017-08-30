#!/bin/bash

export KNOWLEDGEARC_DSPACE_BRANCH=dspace-5_x_knowledgearc
export TOMCAT_MAJOR=8
export TOMCAT_MINOR=8.0.46
useradd -m dspace &&\
    apt-get update &&\
    apt-get install -y \
    wget \
    git \
    postgresql-client \
    default-jre \
    default-jdk \
    maven
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre/

cd /opt

git clone -b ${KNOWLEDGEARC_DSPACE_BRANCH} https://github.com/knowledgearcdotorg/DSpace.git /opt/dspace &&\
    wget http://www-us.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_MINOR}/bin/apache-tomcat-${TOMCAT_MINOR}.tar.gz &&\
    tar -xvzf apache-tomcat-${TOMCAT_MINOR}.tar.gz &&\
    rm -f apache-tomcat-${TOMCAT_MINOR}.tar.gz &&\
    chown -R dspace:dspace /opt/dspace/

cd dspace

nano dspace/config/local.cfg

mvn package &&\
    cd dspace/target/dspace-installer

export POSTGRES_HOST=localhost
export PGPASSWORD=dspace
export POSTGRES_PORT=5432
export DB_USERNAME=dspace
sed -i "s|dspace.dir.*=.*|dspace.dir=/dspace|1" /opt/dspace/dspace/config/local.cfg
sed -i "s|dspace.hostname.*=.*|dspace.hostname=54.89.167.112|1" /opt/dspace/dspace/config/local.cfg
sed -i "s|db.username.*=.*|db.username=dspace|1" /opt/dspace/dspace/config/local.cfg
sed -i "s|db.password.*=.*|db.password=dspace|1" /opt/dspace/dspace/config/local.cfg
sed -i "s|db.url.*=.*|db.url=jdbc:postgresql://localhost:5432/dspace|1" /opt/dspace/dspace/config/local.cfg

cd /opt/dspace/dspace/target/dspace-installer

check=1

while [ ! $check -eq 0 ];
do
    pg_isready -h ${POSTGRES_HOST} -p${POSTGRES_PORT};
    check=$?;
done

#nano /opt/apache-tomcat-8.0.46/conf/server.xml

#ADD entry.sh /entry.sh
#
#ENTRYPOINT /entry.sh
