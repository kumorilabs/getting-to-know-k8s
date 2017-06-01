FROM ruby:2.4.1-alpine
MAINTAINER Steven Eschinger <steven@kumorilabs.com>

USER root

RUN apk add --no-cache libcurl

RUN apk add --no-cache --virtual .build-deps \
    build-base \
    libxml2-dev \
    libxslt-dev

RUN gem install html-proofer

RUN apk del .build-deps