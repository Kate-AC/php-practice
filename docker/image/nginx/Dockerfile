FROM alpine:3.9

RUN apk update
RUN apk add --no-cache nginx=~1.14.2

RUN mkdir -p /run/nginx
RUN mkdir -p /project/php_practice

WORKDIR /project/php_practice

COPY ./docker/config/nginx/default.conf /etc/nginx/conf.d/

