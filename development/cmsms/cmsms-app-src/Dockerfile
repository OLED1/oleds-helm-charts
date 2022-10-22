FROM php:8.0-apache

# Install OS dependencies required
RUN apt-get update && apt-get upgrade -y && apt-get install curl zip libzip-dev libgd-dev libicu-dev -y

# Adapt apache config
RUN a2enmod rewrite
#RUN a2enmod rewrite \
#    && echo "ServerName 127.0.0.1" >> /etc/apache2/apache2.conf

# Configure gd with freetype
RUN docker-php-ext-configure gd

# Install PHP ext-gd
RUN docker-php-ext-install intl gd zip mysqli pdo pdo_mysql opcache

# Copy app content
# Use the .dockerignore file to control what ends up inside the image!
WORKDIR /var/www/html
COPY app .
COPY cmsms-init ./cmsms-init

# Set app owner to apache
RUN chown www-data. * -R

# Expose useful volumes (see documentation)
VOLUME /var/www/html/modules
VOLUME /var/www/html/uploads

RUN chmod 777 /var/www/html/cmsms-init/init-cmsms.php

# Inject default values if content and themes are mounted with empty directories, adjust rights and start the server
CMD ["sh", "-c", "/usr/local/bin/php /var/www/html/cmsms-init/init-cmsms.php && apache2-foreground"]