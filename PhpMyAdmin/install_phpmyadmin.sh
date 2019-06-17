#！/bin/sh
wget -P /usr/local/src https://files.phpmyadmin.net/phpMyAdmin/4.8.3/phpMyAdmin-4.8.3-all-languages.tar.gz
cd /usr/local/src && tar xf phpMyAdmin-4.8.3-all-languages.tar.gz
/bin/mv phpMyAdmin-4.8.3-all-languages /usr/local/nginx/html/phpMyAdmin
/bin/cp /usr/local/nginx/html/phpMyAdmin/{config.sample.inc.php,config.inc.php}
sed -i "s@UploadDir.*@UploadDir'\] = 'upload';@" /usr/local/nginx/html/phpMyAdmin/config.inc.php
sed -i "s@SaveDir.*@SaveDir'\] = 'save';@" /usr/local/nginx/html/phpMyAdmin/config.inc.php
chown -R nginx.nginx /usr/local/nginx/html/phpMyAdmin
sed -i "s@\$cfg\['AllowArbitraryServer'\] = false;@\$cfg\['AllowArbitraryServer'\] = true;@" /usr/local/nginx/html/phpMyAdmin//libraries/config.default.php
