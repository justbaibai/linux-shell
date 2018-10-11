#!/bin/sh
yum install openstack-dashboard -y

if [ $? -eq 0 ]; then
	echo "openstack-dashboard   install   is OK"
else
	echo "openstack-dashboard  install  is NOT OK"
	exit 2
fi


cp -a /etc/openstack-dashboard/local_settings{,.bak}

SetFile=/etc/openstack-dashboard/local_settings



sed -i "/ALLOWED_HOSTS/cALLOWED_HOSTS = ['*', ]" $SetFile

sed -i '/ULTIDOMAIN_SUPPORT/cOPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True' $SetFile

sed -i "s@^#OPENSTACK_KEYSTONE_DEFAULT@OPENSTACK_KEYSTONE_DEFAULT@" $SetFile

sed -i "s#127.0.0.1:11211#10.0.3.111:11211#" $SetFile

sed -in '154,159s/#//' $SetFile

sed -in '161,165s/.*/#&/' $SetFile

sed -i 's#_member_#user#g' $SetFile

sed -i 's#OPENSTACK_HOST = "127.0.0.1"#OPENSTACK_HOST = "10.0.3.111"#' $SetFile

sed -in '317,322s/True/False/' $SetFile

sed -i "323i  'enable_lb': False,"  $SetFile

sed -in '64,70s/#//' $SetFile

sed -i '69d' $SetFile

sed -i '65d' $SetFile


systemctl restart httpd.service memcached.service


 

