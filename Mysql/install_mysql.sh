#!/bin/sh
wget -P /usr/local/src http://mirrors.ustc.edu.cn/mysql-ftp/Downloads/MySQL-5.6/mysql-5.6.43-linux-glibc2.12-x86_64.tar.gz
cd /usr/local/src && tar xf mysql-5.6.43-linux-glibc2.12-x86_64.tar.gz
mv /usr/local/src/mysql-5.6.43-linux-glibc2.12-x86_64 /usr/local/mysql-5.6.43
useradd -s /sbin/nologin -M mysql
chown -R mysql.mysql  /usr/local/mysql-5.6.43/*
yum -y install autoconf libaio-devel
cp /usr/local/mysql-5.6.43/support-files/my-default.cnf /etc/my.cnf
/usr/local/mysql-5.6.43/scripts/mysql_install_db --basedir=/usr/local/mysql-5.6.43/ --datadir=/usr/local/mysql-5.6.43/data/ --user=mysql
#/usr/local/mysql-5.6.43/bin/mysqld_safe&
cp /usr/local/mysql-5.6.43/support-files/mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld
ln -s /usr/local/mysql-5.6.43/  /usr/local/mysql
echo "export PATH=/usr/local/mysql/bin:\$PATH" >> /etc/profile.d/mysql.sh
cat >> /etc/profile << EOF
# mariadb path
PATH=\$PATH:/usr/local/mysql/bin
export PATH
EOF
echo "ok"
. /etc/profile
source /etc/profile.d/mysql.sh
