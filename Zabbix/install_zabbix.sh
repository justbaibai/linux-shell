#!/bin/sh
yum install -y libdbi-dbd-mysql net-snmp-devel curl-devel net-snmp libcurl-devel libxml2-devel
wget -P /usr/local/src https://jaist.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/4.0.3/zabbix-4.0.3.tar.gz
groupadd zabbix
useradd -g zabbix zabbix
/usr/local/mysql/bin/mysql -uroot -p123456 -e "create database zabbix ;"
/usr/local/mysql/bin/mysql -uroot -p123456 -e "grant all on zabbix.* to zabbix@'%' identified by 'zabbix';"
/usr/local/mysql/bin/mysql -uroot -p123456 -e "grant all on zabbix.* to zabbix@'localhost' identified by 'zabbix';"
/usr/local/mysql/bin/mysql -uroot -p123456 -e "flush privileges;"
cd /usr/local/src && tar xf zabbix-4.0.3.tar.gz
cd /usr/local/src/zabbix-4.0.3 && ./configure --prefix=/usr/local/zabbix-4.0.3 --enable-server --enable-agent --with-mysql --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2
make && make install
ln -s /usr/local/zabbix-4.0.3/ /usr/local/zabbix
cd /usr/local/src/zabbix-4.0.3/database/mysql
mysql -uzabbix -pzabbix zabbix < schema.sql
mysql -uzabbix -pzabbix zabbix < images.sql
mysql -uzabbix -pzabbix zabbix < data.sql
sed -i 's@# ListenIP=0.0.0.0@ListenIP=0.0.0.0@g' /usr/local/zabbix/etc/zabbix_server.conf


rm -fr /usr/local/nginx/html/*
cd /usr/local/src/zabbix-4.0.3/frontends/php/
cp -a . /usr/local/nginx/html/
chown -R nginx.nginx /usr/local/nginx/html/*

cd /usr/local/src/zabbix-4.0.3/misc/init.d/
cp fedora/core/zabbix_server /etc/init.d/
cp fedora/core/zabbix_agentd /etc/init.d/
#vim /etc/init.d/zabbix_server
#BASEDIR=/usr/local/zabbix  #找到此行，并修改
#vim /etc/init.d/zabbix_agentd
#BASEDIR=/usr/local/zabbix  #找到此行，并修改
sed -i 's# *.BASEDIR=\/usr\/local# BASEDIR=\/usr\/local\/zabbix#g' /etc/init.d/zabbix_server
sed -i 's# *.BASEDIR=\/usr\/local# BASEDIR=\/usr\/local\/zabbix#g' /etc/init.d/zabbix_agentd
#/tmp/zabbix_server.log  日志
/usr/local/zabbix/sbin/zabbix_server -c /usr/local/zabbix/etc/zabbix_server.conf
mkdir /var/lib/mysql
ln -s /tmp/mysql.sock /var/lib/mysql/mysql.sock
/etc/rc.d/init.d/mysqld restart
