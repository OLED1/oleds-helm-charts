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

# Create a default copy of uploads and modules in case of empty directories binding
RUN mkdir -p /var/www/html/uploads.default/ && \
    cp -R /var/www/html/uploads/* /var/www/html/uploads.default/ && \
    mkdir -p /var/www/html/modules.default/ && \
    cp -R /var/www/html/modules/* /var/www/html/modules.default/

# Make init script executable 
RUN chmod +x /var/www/html/cmsms-init/move_default_files.sh

# Inject default values if uploads and modules are mounted with empty directories, import default database and insert settings stated in env's and 
# adjust rights and start the server
CMD ["sh", "-c", "/bin/sh /var/www/html/cmsms-init/move_default_files.sh && /usr/local/bin/php /var/www/html/cmsms-init/init-cmsms.php && apache2-foreground"]