FROM alpine:latest
MAINTAINER Steven Eschinger <steven@kumorilabs.com>

ENV KUBECTL_VERSION=1.7.6

USER root

RUN apk add --update \
    wget \
    ca-certificates \
    jq

RUN wget https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x kubectl && \
    mv kubectl /usr/bin/kubectl