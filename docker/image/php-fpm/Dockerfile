FROM php:7.4-fpm-alpine

RUN apk update
RUN apk add --no-cache \
  linux-headers \
  autoconf \
  automake \
  bash \
  bzip2-dev \
  curl \
  curl-dev \
  freetype \
  freetype-dev \
  g++ \
  gcc \
  libffi-dev \
  libtool \
  libxml2-dev \
  make \
  musl-dev \
  mysql-client \
  readline \
  ssmtp \
  tar

RUN mkdir -p /var/run/mysqld

RUN docker-php-ext-install \
  mysqli \
  pdo_mysql

WORKDIR /project/php_practice

COPY ./docker/config/php/* /usr/local/etc/php/conf.d/
COPY ./docker/config/php-fpm/* /usr/local/etc/php-fpm.d/
