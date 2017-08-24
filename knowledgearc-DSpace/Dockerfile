FROM ubuntu:16.04

ENV KNOWLEDGEARC_DSPACE_BRANCH dspace-5_x_knowledgearc

ENV TOMCAT_MAJOR 8

ENV TOMCAT_MINOR 8.0.46

RUN useradd -m dspace &&\
    apt-get update &&\
    apt-get install -y \
    wget \
    git \
    postgresql-client \
    default-jre \
    default-jdk \
    maven

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/jre/

WORKDIR /opt

RUN git clone -b ${KNOWLEDGEARC_DSPACE_BRANCH} https://github.com/knowledgearcdotorg/DSpace.git /opt/dspace &&\
    wget http://www-us.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_MINOR}/bin/apache-tomcat-${TOMCAT_MINOR}.tar.gz &&\
    tar -xvzf apache-tomcat-${TOMCAT_MINOR}.tar.gz &&\
    rm -f apache-tomcat-${TOMCAT_MINOR}.tar.gz &&\
    chown -R dspace:dspace /opt/dspace/

WORKDIR dspace

ADD local.cfg dspace/config/local.cfg

RUN mvn package &&\
    cd dspace/target/dspace-installer

ADD entry.sh /entry.sh

ENTRYPOINT /entry.sh
