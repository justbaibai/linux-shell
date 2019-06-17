#!/bin/sh

yum install mariadb mariadb-server python2-PyMySQL -y  >/dev/null 2>&1

if [ $? -eq 0 ]; then
	echo "install mysql  is OK"
else
	echo "install mysql  is NOT OK"
fi
sleep 5s

#cp /etc/my.cnf.d/openstack.cnf{,bak}

echo "#
[mysqld]
bind-address = 0.0.0.0
default-storage-engine = innodb
innodb_file_per_table
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
#">>/etc/my.cnf.d/openstack.cnf


#启动数据库服务
systemctl enable mariadb.service  >/dev/null 2>&1
systemctl start mariadb.service  >/dev/null 2>&1
if [  $? -eq 0 ]; then
	echo "mysql start ok"
else 
	echo "mysql not ok"
fi

netstat -antp|grep mysqld
DBPass=123456
#mysql_secure_installation 
#密码  123456

[[ -f /usr/bin/expect ]] || { yum install expect -y >/dev/null 2>&1; } #若没expect则安装
/usr/bin/expect << EOF
set timeout 30
spawn mysql_secure_installation
expect {
    "enter for none" { send "\r"; exp_continue}
    "Y/n" { send "Y\r" ; exp_continue}
    "password:" { send "$DBPass\r"; exp_continue}
    "new password:" { send "$DBPass\r"; exp_continue}
    "Y/n" { send "Y\r" ; exp_continue}
    eof { exit }
}
EOF

sleep 3s

mysql -u root -p$DBPass -e "show databases;"
[ $? = 0 ] || { echo "mariadb init is not ok";exit; }

echo "mysql is init ok"



