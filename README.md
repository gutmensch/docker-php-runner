# docker-php-runner [![Build Status](https://jenkins.bln.space/buildStatus/icon?job=docker-images%2Fdocker-php-runner%2Fmaster)](https://jenkins.bln.space/job/docker-images/job/docker-php-runner/job/master/)

Forked from [robbertkl/php](https://github.com/robbertkl/docker-php-runner) with original author Robbert Klarenbeek, <robbertkl@renbeek.nl>, thank y  ou!

## Usage

Docker container running PHP-FPM with NGINX:

* Meant to be run behind a reverse proxy doing SSL and/or virtual hosts (for example the awesome [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy))
* Either run it directly with a mounted volume or extend it into an image with your code included
* Logs access to `stdout`, errors to `stderr` (so it shows up in `docker logs`)
* Contains `composer` to install your app dependencies
* Exposes port 80 (HTTP)

## Usage

Either run it directly or extend it:

```
FROM registry.n-os.org:5000/php:7.4

COPY composer.json composer.lock ./
RUN composer install --no-dev
COPY . .

...
```

## Environment variables

You can tweak the behaviour by setting the following environment variables:

* `DOCUMENT_ROOT` (default `/var/www`)
* `PHP_MEMORY_LIMIT` (default 128M)
* `PHP_ERROR_REPORTING` (default E_ALL & ~E_DEPRECATED & ~E_STRICT)
* `TZ` (default unset, which means UTC)


## License

This repo is published under the [MIT License](http://www.opensource.org/licenses/mit-license.php).
