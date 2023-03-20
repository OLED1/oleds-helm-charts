#!/bin/bash
echo "[STEP]Copying default files."
find /var/www/html/uploads -maxdepth 0 -type d -empty -exec cp -R /var/www/html/uploads.default/* /var/www/html/uploads \;
find /var/www/html/modules -maxdepth 0 -type d -empty -exec cp -R /var/www/html/modules.default/* /var/www/html/modules \;
echo "[STEP]Setting default rights www-data:www-data for uploads and modules directory."
chown -R www-data:www-data /var/www/html/uploads
chown -R www-data:www-data /var/www/html/modules