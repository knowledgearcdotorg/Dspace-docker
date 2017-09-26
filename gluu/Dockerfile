FROM ubuntu:16.04

RUN apt-get update &&\
    apt-get install -y curl \
    apt-transport-https \
    netstat &&\
    echo "deb https://repo.gluu.org/ubuntu/ xenial main" > /etc/apt/sources.list.d/gluu-repo.list &&\
    curl https://repo.gluu.org/ubuntu/gluu-apt.key | apt-key add - &&\
    apt-get update &&\
    apt-get install -y gluu-server-3.1.0

RUN service gluu-server-3.1.0 start