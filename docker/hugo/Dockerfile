FROM alpine:latest
MAINTAINER Steven Eschinger <steven@kumorilabs.com>

ENV HUGO_VERSION=0.20.5

USER root

RUN apk add --update \
    wget \
    ca-certificates \
    jq

RUN wget https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz && \
    tar xzf hugo_${HUGO_VERSION}_Linux-64bit.tar.gz && \
    mv hugo /usr/bin/hugo && \
    rm -rf hugo_${HUGO_VERSION}_linux_amd64/