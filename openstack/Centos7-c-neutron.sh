#!/bin/sh
##5.1 neutron控制节点
# 10.0.3.111 安装
#5.1.neutron-10.0.3.111.sh



mysql -u root -p123456 -e "
create database neutron;
grant all privileges on neutron.* to 'neutron'@'localhost' identified by 'neutron';
grant all privileges on neutron.* to 'neutron'@'%' identified by 'neutron';
flush privileges;
select user,host from mysql.user;
show databases;
"

if [ $? -eq 0 ]; then
	echo 'user tables in    neutron in mysql is ok'
else
	echo "neutron  set is NOT OK"
fi


source /root/script/admin-openstack.sh 

openstack user create --domain default --password=neutron neutron   >/dev/null 2>&1 

openstack role add --project service --user neutron admin  >/dev/null 2>&1 


openstack service create --name neutron --description "OpenStack Networking" network   >/dev/null 2>&1 

openstack endpoint create --region RegionOne network public http://10.0.3.111:9696  >/dev/null 2>&1 

openstack endpoint create --region RegionOne network internal http://10.0.3.111:9696 >/dev/null 2>&1 

openstack endpoint create --region RegionOne network admin http://10.0.3.111:9696  >/dev/null 2>&1 

yum install openstack-neutron openstack-neutron-ml2  openstack-neutron-linuxbridge ebtables -y   >/dev/null 2>&1 

if [ $? -eq 0 ]; then
	echo "neutron  install   is OK"
else
	echo "neutron install  is NOT OK"
	exit 2
fi



cp /etc/neutron/neutron.conf{,.bak}

# #nova控制节点配置
echo '#
[database]
connection = mysql+pymysql://neutron:neutron@10.0.3.111/neutron


[DEFAULT]
auth_strategy = keystone
core_plugin = ml2
service_plugins =
transport_url = rabbit://openstack:openstack@10.0.3.111
notify_nova_on_port_status_changes = true
notify_nova_on_port_data_changes = true

[keystone_authtoken]
www_authenticate_uri = http://10.0.3.111:5000
auth_url = http://10.0.3.111:5000
memcached_servers = 10.0.3.111:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = neutron
password = neutron

[nova]
auth_url = http://10.0.3.111:5000
auth_type = password
project_domain_name = default
user_domain_name = default
region_name = RegionOne
project_name = service
username = nova
password = nova

[oslo_concurrency]
lock_path = /var/lib/neutron/tmp
#'>/etc/neutron/neutron.conf

cp /etc/neutron/plugins/ml2/ml2_conf.ini{,.bak}
echo '#
[ml2]
type_drivers = flat,vlan
tenant_network_types =
mechanism_drivers = linuxbridge
extension_drivers = port_security
[ml2_type_flat]
flat_networks = provider
[securitygroup]
enable_ipset = true
#'>/etc/neutron/plugins/ml2/ml2_conf.ini

cp /etc/neutron/plugins/ml2/linuxbridge_agent.ini{,.bak}
echo '#
[linux_bridge]
physical_interface_mappings = provider:eth0
[vxlan]
enable_vxlan = false
[securitygroup]
enable_security_group = true
firewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver

#'>/etc/neutron/plugins/ml2/linuxbridge_agent.ini


cp /etc/neutron/dhcp_agent.ini{,.bak}
echo '#
[DEFAULT]
interface_driver = linuxbridge
dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq
enable_isolated_metadata = true
#'>/etc/neutron/dhcp_agent.ini

cp /etc/neutron/metadata_agent.ini{,.bak}
echo '#
[DEFAULT]
nova_metadata_host = 10.0.3.111
metadata_proxy_shared_secret = metadata
#'>/etc/neutron/metadata_agent.ini

cp /etc/nova/nova.conf{,nebak}
echo '#
[neutron]
url = http://10.0.3.111:9696
auth_url = http://10.0.3.111:5000
auth_type = password
project_domain_name = default
user_domain_name = default
region_name = RegionOne
project_name = service
username = neutron
password = neutron
service_metadata_proxy = true
metadata_proxy_shared_secret = metadata
#'>>/etc/nova/nova.conf
ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini  >/dev/null 2>&1 
su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron  >/dev/null 2>&1 

systemctl restart openstack-nova-api.service  >/dev/null 2>&1 
systemctl enable neutron-server.service   neutron-linuxbridge-agent.service neutron-dhcp-agent.service   neutron-metadata-agent.service  >/dev/null 2>&1 
systemctl start neutron-server.service   neutron-linuxbridge-agent.service neutron-dhcp-agent.service   neutron-metadata-agent.service  >/dev/null 2>&1 







