#!/bin/sh

#install first reboot

yum install -y openstack-nova-compute  >/dev/null 2>&1
if [ $? -eq 0 ];then
	echo "nova-compute install is ok"
else
	echo "nova-compute install is not ok"
fi


[[ `egrep -c '(vmx|svm)' /proc/cpuinfo` = 0 ]] && { Kvm=qemu; } || { Kvm=kvm; }
echo "use $Kvm"


/usr/bin/cp /etc/nova/nova.conf{,.bak}
#egrep -v '^$|#' /etc/nova/nova.conf
echo '#
[DEFAULT]
enabled_apis = osapi_compute,metadata
transport_url = rabbit://openstack:openstack@10.0.3.111
my_ip = 10.0.3.112
use_neutron = True
firewall_driver = nova.virt.firewall.NoopFirewallDriver
#compute_driver = libvirt.LibvirtDriver

[api]
auth_strategy = keystone


[keystone_authtoken]
auth_url = http://10.0.3.111:5000/v3
memcached_servers = 10.0.3.111:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = nova
password = nova


[vnc]
enabled = true
server_listen = 0.0.0.0
server_proxyclient_address = $my_ip
novncproxy_base_url = http://10.0.3.111:6080/vnc_auto.html





[glance]
api_servers = http://10.0.3.111:9292


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


[libvirt]
virt_type = qemu
#'>/etc/nova/nova.conf  >/dev/null 2>&1

if [ $? -eq 0 ];then
	echo "nova-compute conf is ok"
else
	echo "nova-compute conf is not ok"
fi
#sed -i 's#10.0.3.111:6080#10.2.10.20:6080#' /etc/nova/nova.conf

#启动
systemctl enable libvirtd.service openstack-nova-compute.service >/dev/null 2>&1
systemctl start libvirtd.service openstack-nova-compute.service

if [ $? -eq 0 ];then
	echo "nova-compute all install is ok"
else
	echo "nova-compute all install is not ok"
fi