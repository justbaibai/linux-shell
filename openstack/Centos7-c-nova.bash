#!/bin/sh
##5.1 Nova控制节点
# 10.0.3.111 安装
#5.1.Nova-10.0.3.111.sh



mysql -u root -p123456 -e "
create database nova;
grant all privileges on nova.* to 'nova'@'localhost' identified by 'nova';
grant all privileges on nova.* to 'nova'@'%' identified by 'nova';
create database nova_api;
grant all privileges on nova_api.* to 'nova'@'localhost' identified by 'nova';
grant all privileges on nova_api.* to 'nova'@'%' identified by 'nova';
create database nova_cell0;
grant all privileges on nova_cell0.* to 'nova'@'localhost' identified by 'nova';
grant all privileges on nova_cell0.* to 'nova'@'%' identified by 'nova';
CREATE DATABASE placement;
GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'localhost' IDENTIFIED BY 'placement';
GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'%' IDENTIFIED BY 'placement';
flush privileges;
select user,host from mysql.user;
show databases;
"

if [ $? -eq 0 ]; then
	echo 'user tables in 3nova 1placement % localhost and database glance   nova in mysql is ok'
else
	echo "nova  set is NOT OK"
fi

sleep 8s
clear

source /root/script/admin-openstack.sh 


#创建Nova数据库、用户、认证，前面已设置
#source /root/script/admin-openstack.sh || { echo "加载前面设置的admin-openstack.sh环境变量脚本";exit; }
openstack user create --domain default --password=nova nova 
openstack role add --project service --user nova admin

if [ $? -eq 0 ]; then
	echo "nova  create   is OK"
else
	echo "nova create is NOT OK"
fi
sleep 8s
clear



# keystone上服务注册 ,创建nova用户、服务、API
# nova用户前面已建


openstack service create --name nova --description "OpenStack Compute" compute 
openstack endpoint create --region RegionOne compute public http://10.0.3.111:8774/v2.1
openstack endpoint create --region RegionOne compute internal http://10.0.3.111:8774/v2.1
openstack endpoint create --region RegionOne compute admin http://10.0.3.111:8774/v2.1

if [ $? -eq 0 ]; then
	echo "nova  create   is OK"
else
	echo "nova create is NOT OK"
fi
sleep 8s

#创建placement用户、服务、API

openstack user create --domain default --password=placement placement
openstack role add --project service --user placement admin 
openstack service create --name placement --description "Placement API" placement 
openstack endpoint create --region RegionOne placement public http://10.0.3.111:8778 
openstack endpoint create --region RegionOne placement internal http://10.0.3.111:8778 
openstack endpoint create --region RegionOne placement admin http://10.0.3.111:8778
#openstack endpoint delete id?

if [ $? -eq 0 ]; then
	echo "nova  placement  is OK"
else
	echo "nova placement is NOT OK"
fi
sleep 8s




## 安装nova控制节点
yum install -y openstack-nova-api openstack-nova-conductor \
  openstack-nova-console openstack-nova-novncproxy \
  openstack-nova-scheduler openstack-nova-placement-api 
if [ $? -eq 0 ]; then
	echo "nova  install   is OK"
else
	echo "nova install  is NOT OK"
fi

yum install -y openstack-utils >/dev/null 2>&1 &&

cp /etc/nova/nova.conf{,.bak}

# #nova控制节点配置
echo '#
[DEFAULT]
enabled_apis = osapi_compute,metadata
transport_url = rabbit://openstack:openstack@10.0.3.111
my_ip = 10.0.3.111
use_neutron = true
firewall_driver = nova.virt.firewall.NoopFirewallDriver
[api]
auth_strategy = keystone
[api_database]
connection = mysql+pymysql://nova:nova@10.0.3.111/nova_api
[database]
connection = mysql+pymysql://nova:nova@10.0.3.111/nova
[glance]
api_servers = http://10.0.3.111:9292
[keystone_authtoken]
auth_url = http://10.0.3.111:5000/v3
memcached_servers = 10.0.3.111:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = nova
password = nova
[oslo_concurrency]
lock_path = /var/lib/nova/tmp
[placement]
region_name = RegionOne
project_domain_name = Default
project_name = service
auth_type = password
user_domain_name = Default
auth_url = http://10.0.3.111:5000/v3
username = placement
password = placement
[placement_database]
connection = mysql+pymysql://placement:placement@10.0.3.111/placement
[vnc]
enabled = true
vncserver_listen = $my_ip
vncserver_proxyclient_address = $my_ip
[scheduler]
discover_hosts_in_cells_interval = 300
#'>/etc/nova/nova.conf




cp /etc/httpd/conf.d/00-nova-placement-api.conf{,.bak}
echo "

#Placement API
<Directory /usr/bin>
   <IfVersion >= 2.4>
      Require all granted
   </IfVersion>
   <IfVersion < 2.4>
      Order allow,deny
      Allow from all
   </IfVersion>
</Directory>
">>/etc/httpd/conf.d/00-nova-placement-api.conf
systemctl restart httpd

if [ $? -eq 0 ]; then
	echo "nova  conf  for httpd   is OK"
else
	echo "nova conf for httpd   is NOT OK"
fi


sleep 2

#同步数据库
su -s /bin/sh -c "nova-manage api_db sync" nova >/dev/null 2>&1   
su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova >/dev/null 2>&1  
su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova 

su -s /bin/sh -c "nova-manage db sync" nova >/dev/null 2>&1 


if [ $? -eq 0 ]; then
	echo "nova  init db   is OK"
else
	echo "nova init db   is NOT OK"
fi

sleep 3s


clear


#检测数据
#nova-manage cell_v2 list_cells

su -s /bin/sh -c "nova-manage cell_v2 list_cells" nova


echo " have cell1 cell0  is ok "
sleep 3s
mysql -h 10.0.3.111 -u nova -pnova -e "use nova_api;show tables;"
mysql -h 10.0.3.111 -u nova -pnova -e "use nova;show tables;" 
mysql -h 10.0.3.111 -u nova -pnova -e "use nova_cell0;show tables;"


echo "novaapi nov  novcello  3tables  is ok ?"

sleep 8s




#开机自启动
 systemctl enable openstack-nova-api.service \
  openstack-nova-consoleauth.service openstack-nova-scheduler.service \
  openstack-nova-conductor.service openstack-nova-novncproxy.service  
#启动服务
systemctl start openstack-nova-api.service \
  openstack-nova-consoleauth.service openstack-nova-scheduler.service \
  openstack-nova-conductor.service openstack-nova-novncproxy.service

if [ $? -eq 0 ]; then
	echo "nova  all   is OK"
else
	echo "nova  is NOT OK"
fi


  
  
#查看节点
#nova service-list 
#openstack catalog list
#nova-status upgrade check
#openstack compute service list

#nova-manage cell_v2 delete_cell --cell_uuid  b736f4f4-2a67-4e60-952a-14b5a68b0f79

# #发现计算节点,新增计算节点时执行
#su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova

