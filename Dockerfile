ARG ALPINE_VERSION=3.15
FROM alpine:$ALPINE_VERSION

ARG PHP_USER_UID=2000
ARG PHP_USER_GID=2000
ARG S6_VERSION=2.2.0.3

COPY manifest /

RUN apk update \
  \
  # install base packages \
  && apk add nginx curl bash gettext \
  \
  # install php modules and process manager \
  && apk add php7 \
    php7-bcmath \
    php7-common \
    php7-ctype \
    php7-curl \
    php7-fpm \
    php7-gd \
    php7-iconv \
    php7-intl \
    php7-json \
    php7-mbstring \
    php7-mcrypt \
    php7-mysqli \
    php7-mysqlnd \
    php7-openssl \
    php7-pear \
    php7-pecl-memcached \
    php7-phar \
    php7-sqlite3 \
    php7-xml \
    php7-zip \
    \
  # add application user \
  && addgroup -S -g $PHP_USER_GID phpapp \
  && adduser -S -G phpapp -u $PHP_USER_UID phpapp \
  \
  # adjust permissions \
  && chgrp -R phpapp /var/run /run \
  && chmod -R g+w /var/run /run \
  && chown -R phpapp:phpapp /var/log/nginx /var/log/php7 /var/lib/nginx /etc/nginx /etc/php7 /var/www \
  \
  # install s6-overlay \
  && curl -sSL "https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-amd64.tar.gz" \
    | tar xvzf - -C / \
 && sed -i "s/s6-nuke -th/s6-nuke -t/" /etc/s6/init/init-stage3 \
 && chown -R phpapp:phpapp /etc/s6 /etc/services.d

# variables for s6 service configuration
ENV DOCUMENT_ROOT=/var/www \
    UPLOAD_POST_BODY_MAX_MB=128 \
    NGINX_LISTEN_PORT=8080 \
    PHP_MEMORY_LIMIT_MB=128 \
    PHP_ERROR_REPORTING="E_ALL & ~E_DEPRECATED & ~E_STRICT"

HEALTHCHECK --interval=20s --timeout=5s --retries=3  CMD curl --fail -si 127.0.0.1:8080/ping

EXPOSE 8080

USER phpapp

# run s6 service supervisor (not as entrypoint!)
CMD [ "/init" ]
