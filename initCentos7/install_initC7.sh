#!/bin/sh
yum install -y wget vim dos2unix lrzsz
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
mv /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo.backup
mv /etc/yum.repos.d/epel-testing.repo /etc/yum.repos.d/epel-testing.repo.backup
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
setenforce 0
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config
sed -i 's/#GSSAPIAuthentication\ no/GSSAPIAuthentication\ no/g' /etc/ssh/sshd_config
sed -i 's/GSSAPIAuthentication\ yes/#GSSAPIAuthentication\ yes/g' /etc/ssh/sshd_config
sed -i 's/#UseDNS\ yes/UseDNS\ no/g' /etc/ssh/sshd_config
systemctl restart sshd
echo '* - nofile 65535' >> /etc/security/limits.conf

echo "net.ipv4.tcp_fin_timeout = 20
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 10000 65000
net.core.netdev_max_backlog = 32768
net.core.somaxconn = 32768
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 9000
">>/etc/sysctl.conf
sysctl -p

echo "
DefaultLimitCORE=infinity
DefaultLimitNOFILE=65535
DefaultLimitNPROC=65535
" >>/etc/systemd/system.conf

systemctl stop firewalld
echo "start reboot"
sleep 5s
reboot
