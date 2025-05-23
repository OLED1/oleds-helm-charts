#!/bin/bash
echo "[STEP]Copying default files."
find /var/www/html/uploads -maxdepth 0 -type d -empty -exec cp -R /var/www/html/uploads.default/* /var/www/html/uploads \;
find /var/www/html/modules -maxdepth 0 -type d -empty -exec cp -R /var/www/html/modules.default/* /var/www/html/modules \;
echo "[STEP]Creating and symlinking module_custom folder."
mkdir -p /var/www/html/uploads/assets/module_custom
cp -f /var/www/html/assets/module_custom/index.html /var/www/html/uploads/assets/module_custom/
rm -rf /var/www/html/assets/module_custom
ln -s /var/www/html/uploads/assets/module_custom /var/www/html/assets/module_custom
echo "[STEP]Setting default rights www-data:www-data for uploads and modules directory."
chown -R www-data:www-data /var/www/html/uploads
chown -R www-data:www-data /var/www/html/modules
echo "[STEP]Starting pod PHP init script."