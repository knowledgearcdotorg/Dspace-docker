FROM ubuntu:16.04

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

RUN wget https://github.com/DSpace/DSpace/releases/download/dspace-6.1/dspace-6.1-src-release.tar.gz &&\
    tar -xvzf dspace-6.1-src-release.tar.gz &&\
    rm -f dspace-6.1-src-release.tar.gz &&\
    wget http://www-eu.apache.org/dist/tomcat/tomcat-8/v8.0.45/bin/apache-tomcat-8.0.45.tar.gz &&\
    tar -xvzf apache-tomcat-8.0.45.tar.gz &&\
    rm -f apache-tomcat-8.0.45.tar.gz &&\
    chown -R dspace:dspace /opt/dspace-6.1-src-release/

WORKDIR dspace-6.1-src-release

ADD local.cfg dspace/config/local.cfg

RUN mvn package &&\
    cd dspace/target/dspace-installer

ADD entry.sh /entry.sh

ENTRYPOINT /entry.sh
