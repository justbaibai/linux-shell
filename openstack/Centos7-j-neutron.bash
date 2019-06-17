#!/bin/sh

yum install openstack-neutron-linuxbridge ebtables ipset -y  >/dev/null 2>&1 

if [ $? -eq 0 ]; then
	echo "neutron  install   is OK"
else
	echo "neutron install  is NOT OK"
	exit 2
fi

cp /etc/neutron/neutron.conf{,.bak}
echo '#
[DEFAULT]
transport_url = rabbit://openstack:openstack@10.0.3.111
auth_strategy = keystone

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
[oslo_concurrency]
lock_path = /var/lib/neutron/tmp
#'>/etc/neutron/neutron.conf

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

cp /etc/nova/nova.conf{,.nebak}
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
#'>>/etc/nova/nova.conf
systemctl restart openstack-nova-compute.service  >/dev/null 2>&1 
systemctl enable neutron-linuxbridge-agent.service  >/dev/null 2>&1 
systemctl start neutron-linuxbridge-agent.service  >/dev/null 2>&1 

