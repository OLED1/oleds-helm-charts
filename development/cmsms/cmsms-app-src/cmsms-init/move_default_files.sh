#!/bin/bash
echo "[STEP]Copying default files."
find /var/www/html/uploads -type d -empty -exec cp -R /var/www/html/uploads.default/* /var/www/html/uploads \;
find /var/www/html/modules -type d -empty -exec cp -R /var/www/html/modules.default/* /var/www/html/modules \;
chown -R www-data:www-data /var/www/html/uploads
chown -R www-data:www-data /var/www/html/modules