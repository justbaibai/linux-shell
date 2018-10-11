#!/bin/sh

mysql -u root -p123456 -e "
create database glance;
grant all privileges on glance.* to 'glance'@'localhost' identified by 'glance';
grant all privileges on glance.* to 'glance'@'%' identified by 'glance';
flush privileges;
select user,host from mysql.user;
show databases;
"
echo 'user tables in glance % localhost and database glance   kestone in mysql is ok'
sleep 8s
clear

source /root/script/admin-openstack.sh || { echo "加载前面设置的admin-openstack.sh环境变量脚本";exit; }

openstack user create --domain default --password=glance glance

if [ $? -eq 0 ]; then
	echo "glance  service  set   is OK"
else
	echo "glance service set is NOT OK"
fi

openstack role add --project service --user glance admin

sleep 3s
clear 
#source /root/script/demo-openstack.sh || { echo "加载前面设置的admin-openstack.sh环境变量脚本";exit; }
openstack service create --name glance --description "OpenStack Image" image &&
openstack endpoint create --region RegionOne image public http://10.0.3.111:9292
openstack endpoint create --region RegionOne image internal http://10.0.3.111:9292
openstack endpoint create --region RegionOne image admin http://10.0.3.111:9292


if [ $? -eq 0 ]; then
	echo "Image API set and   have four tables   is OK"
else
	echo "Image API set is NOT OK"
fi
sleep 8s 
clear

# Glance 安装
yum install -y openstack-glance python-glance  >/dev/null 2>&1 


if [ $? -eq 0 ]; then
	echo "glance install    is OK"
else
	echo "glance install  is NOT OK"
fi
#配置
cp /etc/glance/glance-api.conf{,.bak}
cp /etc/glance/glance-registry.conf{,.bak}
# images默认/var/lib/glance/images/
#Imgdir=/XLH_DATE/images
#mkdir -p $Imgdir
#chown glance:nobody $Imgdir
#echo "镜像目录： $Imgdir"
echo "#
[database]
connection = mysql+pymysql://glance:glance@10.0.3.111/glance
[keystone_authtoken]
www_authenticate_uri = http://10.0.3.111:5000
auth_url = http://10.0.3.111:5000
memcached_servers = 10.0.3.111:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = glance
password = glance
[paste_deploy]
flavor = keystone
[glance_store]
stores = file,http
default_store = file
filesystem_store_datadir = /var/lib/glance/images/
#">/etc/glance/glance-api.conf
#
echo "#
[database]
connection = mysql+pymysql://glance:glance@10.0.3.111/glance
[keystone_authtoken]
www_authenticate_uri = http://10.0.3.111:5000
auth_url = http://10.0.3.111:5000
memcached_servers = 10.0.3.111:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = glance
password = glance
[paste_deploy]
flavor = keystone
#">/etc/glance/glance-registry.conf

#同步数据库,检查数据库
su -s /bin/sh -c "glance-manage db_sync" glance >/dev/null 2>&1 
if [ $? -eq 0 ]; then
	echo "glance init   is OK"
else
	echo "glance init  is NOT OK"
fi


mysql -h 10.0.3.111 -u glance -pglance -e "use glance;show tables;"

if [ $? -eq 0 ]; then
	echo "glance have tables  is OK"
else
	echo "glance have not tables  is NOT OK"
fi


#启动服务并设置开机自启动
systemctl enable openstack-glance-api openstack-glance-registry   >/dev/null 2>&1 
systemctl start openstack-glance-api openstack-glance-registry     >/dev/null 2>&1 

if [ $? -eq 0 ]; then
	echo "glance all   is OK"
else
	echo "glance all  is NOT OK"
fi

#systemctl restart openstack-glance-api  openstack-glance-registry





netstat -antp | egrep ':9292|:9191' 



echo "9292 and 9191 is ok ?"
sleep 7s
clear 




#镜像测试,下载有时很慢
wget http://download.cirros-cloud.net/0.3.5/cirros-0.3.5-x86_64-disk.img #下载测试镜像源
#使用qcow2磁盘格式，bare容器格式,上传镜像到镜像服务并设置公共可见
#source ./admin-openstack.sh
openstack image create "cirros" \
  --file cirros-0.3.5-x86_64-disk.img \
  --disk-format qcow2 --container-format bare \
  --public

#检查是否上传成功
openstack image list

if [ $? -eq 0 ]; then
	echo "glance image  all all   is OK"
else
	echo "glance image  is NOT OK"
fi
#glance image-list
#ls $Imgdir

#删除镜像 glance image-delete 镜像id