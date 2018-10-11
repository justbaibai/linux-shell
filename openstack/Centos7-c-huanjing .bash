#!bin/sh

#安装
yum -y install wget vim  net-tools tree openssh  >/dev/null 2>&1 

if [ $? -eq 0 ]; then
	echo "tools  is OK"
else
	echo "tools  is NOT OK"
fi
sleep 5s


#更换阿里源
mv /etc/yum.repos.d/CentOS-Base.repo{,.bak}
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo >/dev/null 2>&1 
if [ $? -eq 0 ]; then
	echo "aliyun yum is OK"
else
	echo "aliyun yum is NOT OK"
fi
sleep 5s


#安装OpenStack库
yum install centos-release-openstack-rocky -y >/dev/null 2>&1 
#生成缓存
#yum clean all && yum makecache 

if [ $? -eq 0 ]; then
	echo "centos-release-openstack-rocky OK"
else
	echo "centos-release-openstack-rocky OK"
fi
sleep 5s

#OpenStack客户端
yum install python-openstackclient openstack-selinux python2-PyMySQL openstack-utils  -y  >/dev/null 2>&1 #OpenStack客户端
#yum install openstack-utils -y #openstack工具 

if [ $? -eq 0 ]; then
	echo "OpenStack clien OK"
else
	echo "OpenStack clien NOT OK"
fi
sleep 5s

#关闭selinux、防火墙
systemctl stop firewalld.service 
systemctl disable firewalld.service >/dev/null 2>&1 

if [ $? -eq 0 ]; then
	echo "firewall OK"
else
	echo "firewall NOT OK"
fi
sleep 5s

firewall-cmd --state
sed -i '/^SELINUX=.*/c SELINUX=disabled' /etc/selinux/config
sed -i 's/^SELINUXTYPE=.*/SELINUXTYPE=disabled/g' /etc/selinux/config
grep --color=auto '^SELINUX' /etc/selinux/config
setenforce 0


#vi /etc/hosts
echo "10.0.3.111 baibaic baibaic.com"  >>  /etc/hosts
echo  "10.0.3.112 baibaij baibaij.com"  >>  /etc/hosts

#cat /etc/hosts



echo "baibaic" > /etc/hostname
hostname baibaic

#cat /etc/hostname

yum install chrony  -y  >/dev/null 2>&1 

if [ $? -eq 0 ]; then
	echo "chrony OK"
else
	echo "chrony NOT OK"
fi

#vi /etc/chrony.conf
#allow 10.0.0.0/24
sed -i 's@#allow 192.168.0.0/16@allow 10.0.0.0/24@g' /etc/chrony.conf


timedatectl set-timezone Asia/Shanghai

systemctl enable chronyd.service
systemctl restart chronyd.service
timedatectl set-timezone Asia/Shanghai
chronyc sources

echo "all ok then reboot "


