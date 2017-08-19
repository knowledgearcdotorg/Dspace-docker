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
    wget http://www-us.apache.org/dist/tomcat/tomcat-9/v9.0.0.M26/bin/apache-tomcat-9.0.0.M26.tar.gz &&\
    tar -xvzf apache-tomcat-9.0.0.M26.tar.gz &&\
    rm -f apache-tomcat-9.0.0.M26.tar.gz &&\
    chown -R dspace:dspace /opt/dspace-6.1-src-release/

WORKDIR dspace-6.1-src-release

ADD local.cfg dspace/config/local.cfg

RUN mvn package &&\
    cd dspace/target/dspace-installer &&\
    cp -r webapps/xmlui webapps/oai webapps/solr webapps/rest /opt/apache-tomcat-9.0.0.M26/webapps

RUN wget -O /wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh &&\
    chmod +x /wait-for-it.sh

ADD entry.sh /entry.sh

ENTRYPOINT /entry.sh
