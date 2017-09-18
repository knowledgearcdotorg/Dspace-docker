FROM alpine:3.6

RUN apk add --no-cache \
    py2-pip \
    gettext \
    bash \
    curl \
    jq

RUN pip install awscli

ADD entry.sh /entry.sh

ENTRYPOINT /entry.sh
