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

# Install server dependencies
# RUN chmod +x /var/www/html/docker-utils/install-composer && \
#    /var/www/html/docker-utils/install-composer && \
#    ./composer.phar update && \
#    chmod +x /var/www/html/docker-utils/init-server

# Expose useful volumes (see documentation)
# VOLUME /var/www/html/settings
# VOLUME /var/www/html/media
# VOLUME /var/www/html/cache
# VOLUME /var/www/html/plugins

# Create a default copy of content and theme in case of empty directories binding
# RUN mkdir -p /var/www/html/content.default/ && \
#    cp -R /var/www/html/content/* /var/www/html/content.default/ && \
#    mkdir -p /var/www/html/themes.default/ && \
#    cp -R /var/www/html/themes/* /var/www/html/themes.default/

# VOLUME /var/www/html/content
# VOLUME /var/www/html/themes

# Inject default values if content and themes are mounted with empty directories, adjust rights and start the server
# CMD ["/var/www/html/docker-utils/init-server"]