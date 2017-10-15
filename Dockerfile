FROM php:7.1-fpm-jessie
MAINTAINER Sylius Docker Team <docker@sylius.org>

ENV DEBIAN_FRONTEND noninteractive
ENV DEBIAN_CODENAME jessie
ENV TZ UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
	&& echo $TZ > /etc/timezone \
	&& dpkg-reconfigure -f noninteractive tzdata

# All things PHP
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
        git \
        vim \
        zlib1g-dev \
		libicu52 \
        libicu-dev \
		libpng-dev \
		libfreetype6-dev \
		libjpeg62-turbo-dev \
		libmcrypt4 \
		libmcrypt-dev \
	&& apt-get clean all \
	&& docker-php-ext-enable \
		opcache \
	&& docker-php-ext-install \
		intl \
		zip \
		exif \
		gd \
		pdo \
		pdo_mysql \
		mcrypt \
	&& apt-get purge -y \
		zlib1g-dev \
		libicu-dev \
		libpng-dev \
		libfreetype6-dev \
		libjpeg62-turbo-dev \
		libmcrypt-dev \
	&& apt-get autoremove -y

# Sylius PHP configuration
COPY php/sylius.ini /usr/local/etc/php/conf.d/sylius.ini

# All things composer
RUN php -r 'readfile("https://getcomposer.org/installer");' > composer-setup.php \
	&& php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
	&& rm -f composer-setup.php \
	&& chown www-data.www-data /var/www

# Prepare entrypoint.d pattern
COPY entrypoint.sh /entrypoint.sh
RUN mkdir /entrypoint.d

# Speedup composer
USER www-data
RUN composer global require hirak/prestissimo
USER root

# PHP configuration
COPY php/sylius.ini /usr/local/etc/php/conf.d/sylius.ini

# All things nginx
RUN apt-key adv --fetch-keys http://nginx.org/keys/nginx_signing.key \
    && echo "deb http://nginx.org/packages/mainline/debian/ ${DEBIAN_CODENAME} nginx" > /etc/apt/sources.list.d/nginx.list \
    && apt-get update \
    && apt-get install -y \
		supervisor \
		nginx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && ln -sf /proc/1/fd/1 /var/log/nginx/access.log \
    && ln -sf /proc/1/fd/2 /var/log/nginx/error.log

COPY supervisor/sylius.conf /etc/supervisor/conf.d/sylius.conf

ENTRYPOINT ["/entrypoint.sh", "/usr/bin/supervisord"]
CMD ["-c", "/etc/supervisor/supervisord.conf"]
