FROM ubuntu:16.04

ENV KNOWLEDGEARC_DSPACE_BRANCH dspace-5_x_knowledgearc

ENV TOMCAT_MAJOR 8

ENV TOMCAT_MINOR 8.0.46

RUN useradd -m dspace &&\
    apt-get update &&\
    apt-get install -y \
    python-setuptools \
    unzip \
    wget \
    git \
    postgresql-client \
    default-jdk \
    default-jre \
    gettext \
    maven

RUN easy_install pip &&\
    pip install awscli

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/jre/

WORKDIR /tmp

RUN wget https://github.com/knowledgearcdotorg/DSpace/archive/dspace-5.8-knowledgearc.zip &&\
    unzip dspace-5.8-knowledgearc.zip &&\
    mv DSpace-dspace-5.8-knowledgearc/* /tmp/dspace &&\
    rm -rf DSpace-dspace-5.8-knowledgearc/ &&\
    wget http://www-us.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_MINOR}/bin/apache-tomcat-${TOMCAT_MINOR}.tar.gz &&\
    tar -xvzf apache-tomcat-${TOMCAT_MINOR}.tar.gz &&\
    mv apache-tomcat-${TOMCAT_MINOR}  /opt &&\
    rm -f apache-tomcat-${TOMCAT_MINOR}.tar.gz &&\
    chown -R dspace:dspace /tmp/dspace/

WORKDIR dspace

RUN mvn package &&\
    cd dspace/target/dspace-installer

ADD server.xml /opt/apache-tomcat-8.0.46/conf/server.xml

ADD entry.sh /entry.sh

ENTRYPOINT /entry.sh
