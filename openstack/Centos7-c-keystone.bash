#!bin/sh

#安装
yum -y install openstack-keystone httpd mod_wsgi  >/dev/null 2>&1 

if [ $? -eq 0 ]; then
	echo "keystone  is OK"
else
	echo "keystone  is NOT OK"
fi
sleep 5s

mysql -u root -p123456 -e "
create database keystone;
grant all privileges on keystone.* to 'keystone'@'localhost' identified by 'keystone';
grant all privileges on keystone.* to 'keystone'@'%' identified by 'keystone';
flush privileges;
select user,host from mysql.user;
show databases;
"
echo 'user tables in kestone % localhost and database kestone   kestone in mysql is ok'
sleep 8s
clear
cp /etc/keystone/keystone.conf{,.bak}  #备份默认配置
Keys=$(openssl rand -hex 10)  #生成随机密码
echo "$Keys in openstack.log on home "
echo "kestone  $Keys">>~/openstack.log

if [ $? -eq 0 ]; then
	echo "keystone passwd  is OK"
else
	echo "keystone passwd is NOT OK"
fi


echo "
[DEFAULT]
admin_token = $Keys
[database]
connection = mysql+pymysql://keystone:keystone@10.0.3.111/keystone
[token]
provider = fernet
">/etc/keystone/keystone.conf

su -s /bin/sh -c "keystone-manage db_sync" keystone

if [ $? -eq 0 ]; then
	echo "keystone db init  is OK"
else
	echo "keystone db init is NOT OK"
fi

sleep 5s

clear

mysql -h 10.0.3.111 -ukeystone -pkeystone -e "use keystone;show tables;"

echo "have a tables  is keystone tables is very ok"

keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone &&
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

if [ $? -eq 0 ]; then
	echo "keystone Initialize Fernet key   is OK"
else
	echo "keystone Initialize Fernet key is NOT OK"
fi


keystone-manage bootstrap --bootstrap-password admin \
  --bootstrap-admin-url http://10.0.3.111:5000/v3/ \
  --bootstrap-internal-url http://10.0.3.111:5000/v3/ \
  --bootstrap-public-url http://10.0.3.111:5000/v3/ \
  --bootstrap-region-id RegionOne


if [ $? -eq 0 ]; then
	echo "a suitable password for an administrative user.  is OK"
else
	echo "a suitable password for an administrative user.is NOT OK"
fi

#apache配置
cp /etc/httpd/conf/httpd.conf{,.bak}
echo "ServerName 10.0.3.111">>/etc/httpd/conf/httpd.conf
ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/


#Apache HTTP 启动并设置开机自启动
systemctl enable httpd.service >/dev/null 2>&1 
systemctl restart httpd.service


if [ $? -eq 0 ]; then
	echo "httpd set   is OK"
else
	echo "httpd set is NOT OK"
fi

netstat -antp|egrep ':5000|:80'

echo "is 80 and 5000 is ok"

sleep 5s

clear


export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=admin
export OS_AUTH_URL=http://10.0.3.111:5000/v3
export OS_IDENTITY_API_VERSION=3


openstack project create --domain default --description "Service Project" service
if [ $? -eq 0 ]; then
	echo "domain service  set   is OK"
else
	echo "domain service set is NOT OK"
fi



#创建demo项目(普通用户密码及角色)
openstack project create --domain default --description "Demo Project" demo
openstack user create --domain default --password=demo demo
openstack role create user
openstack role add --project demo --user demo user

if [ $? -eq 0 ]; then
	echo "demo   set   is OK"
else
	echo "demo  set is NOT OK"
fi

sleep 5s
clear
#demo环境脚本
echo "
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=demo
export OS_AUTH_URL=http://10.0.3.111:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
">/root/script/demo-openstack.sh


source /root/script/demo-openstack.sh
openstack token issue


echo "have a token  is   demo is all ok"
sleep 3s
clear 

echo "
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=admin
export OS_AUTH_URL=http://10.0.3.111:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
">/root/script/admin-openstack.sh
source /root/script/admin-openstack.sh
openstack token issue

echo "have a token  is   admin is all ok"
sleep 3s

