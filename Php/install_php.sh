#!/bin/sh
yum install  libjpeg-turbo-devel libmcrypt-devel  mhash mcrypt libxslt-devel  zlib-devel libxml2-devel libjpeg-devel freetype-devel libpng-devel  gd-devel libcurl-devel libiconv-devel libevent-devel  -y
wget -P /usr/local/src   http://www.php.net/distributions/php-5.6.38.tar.gz
cd  /usr/local/src && tar xf php-5.6.38.tar.gz
cd  /usr/local/src/php-5.6.38 &&  ./configure --prefix=/usr/local/php-5.6.38 --with-mysql=mysqlnd --with-mysqli=mysqlnd  --with-pdo-mysql=mysqlnd --with-iconv-dir=/usr/local/libiconv --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-fpm --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-soap --enable-short-tags --enable-static --with-xsl --enable-ftp --enable-opcache --with-fpm-user=nginx --with-fpm-group=nginx
make && make install
ln -s /usr/local/php-5.6.38/  /usr/local/php
cp /usr/local/php-5.6.38/etc/php-fpm.conf.default /usr/local/php-5.6.38/etc/php-fpm.conf
cp /usr/local/src/php-5.6.38/php.ini-production  /usr/local/php/lib/php.ini
