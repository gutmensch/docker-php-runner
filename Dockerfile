ARG IMAGE_VERSION=3.15

FROM registry.n-os.org:5000/root-ca:20220205 AS certs

FROM alpine:$IMAGE_VERSION

ARG IMAGE_UID=2000
ARG IMAGE_GID=2000
ARG S6_VERSION=2.2.0.3

COPY --from=certs /CA/certs/common/ /etc/ssl/certs/common/
COPY manifest /

RUN apk update \
  \
  # install base packages \
  && apk add nginx curl bash gettext tzdata \
  \
  # install php modules and process manager \
  && apk add php7 \
    php7-bcmath \
    php7-common \
    php7-ctype \
    php7-curl \
    php7-dom \
    php7-exif \
    php7-fileinfo \
    php7-fpm \
    php7-gd \
    php7-gmp \
    php7-iconv \
    php7-imap \
    php7-intl \
    php7-json \
    php7-ldap \
    php7-mbstring \
    php7-mcrypt \
    php7-mysqli \
    php7-mysqlnd \
    php7-openssl \
    php7-pcntl \
    php7-pgsql \
    php7-pdo \
    php7-pdo_mysql \
    php7-pdo_pgsql \
    php7-pdo_sqlite \
    php7-pear \
    php7-pecl-memcached \
    php7-pecl-redis \
    php7-phar \
    php7-posix \
    php7-session \
    php7-shmop \
    php7-sqlite3 \
    php7-xml \
    php7-zip \
    \
  # add application user \
  && addgroup -S -g $IMAGE_GID phpapp \
  && adduser -S -G phpapp -u $IMAGE_UID phpapp \
  \
  # adjust permissions \
  && mkdir /var/run/s6 \
  && chown -R phpapp:phpapp /run /var/run /var/log/nginx /var/log/php7 /var/lib/nginx /etc/nginx /etc/php7 /var/www \
  \
  # make timezone adjustable \
  && touch /var/run/s6/localtime /var/run/s6/timezone \
  && rm -f /etc/localtime && ln -s /var/run/s6/localtime /etc/localtime \
  && rm -f /etc/timezone && ln -s /var/run/s6/timezone /etc/timezone \
  # install s6-overlay \
  && curl -sSL "https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-amd64.tar.gz" \
    | tar xvzf - -C / \
  && sed -i "s/s6-nuke -th/s6-nuke -t/" /etc/s6/init/init-stage3 \
  && chown -R phpapp:phpapp /etc/s6 /etc/services.d /etc/cont-init.d \
  && /etc/ssl/certs/common/setup.sh

# variables for s6 service configuration
ENV DOCUMENT_ROOT=/var/www \
    UPLOAD_POST_BODY_MAX_MB=128 \
    NGINX_LISTEN_PORT=8080 \
    PHP_MEMORY_LIMIT_MB=128 \
    PHP_ERROR_REPORTING="E_ALL & ~E_DEPRECATED & ~E_STRICT"

HEALTHCHECK --interval=20s --timeout=5s --retries=3  CMD curl --fail -s 127.0.0.1:8080/ping

EXPOSE 8080

USER phpapp

# run s6 service supervisor (not as entrypoint!)
CMD [ "/init" ]
