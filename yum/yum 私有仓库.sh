#!/bin/sh 
cd /etc/yum.repos.d/
mv CentOS* bak
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
 yum repolist
 yum install createrepo yum-utils -y

 .同步镜像到本地
显示所有仓库
reposync -r base
reposync -r extras
reposync -r updates
reposync -r epel
#createrepo --update
#reposync -r base -p /data #将已经配置好的阿里仓库镜像内的rpm包拉到本地,b ase为本地已经配


cd base
createrepo ./
cd ../extras
createrepo ./
cd ../updates
createrepo ./
cd ../epel
createrepo ./



server {
    listen       80;
    server_name  localhost;
    root /yumrepo;
    #charset koi8-r;

    #access_log  logs/host.access.log  main;

    location / {
        autoindex on;
        autoindex_exact_size off;
        autoindex_localtime on;
    }

vim /cron/repository.sh #编写同步脚本
reposync -r base -p /mirrors/Packege -d #来删除本地老旧
reposync -r base -p /mirrors/Packege
crontab -e #添加定时任务
0 0 1 * * sh /cron/repository.sh #每月1日0时更新yum仓库


/etc/yum.repos.d
mkdir bak
mv * bak
yum clean all

yum makecache
vim /etc/yum.repos.d/baibai.repo

[base]
name=CentOS-Base(GDS)
baseurl=http://10.0.3.163/base
path=/
enabled=1
gpgcheck=0

[updates]
name=CentOS-Updates(GDS)
baseurl=http://10.0.3.163/updates
path=/
enabled=1
gpgcheck=0

[extras]
name=CentOS-Extras(GDS)
baseurl=http://10.0.3.163/extras
path=/
enabled=1
gpgcheck=0

vim /etc/yum.repos.d/baibai-epel.repo
[epel]
name=CentOS-Epel(GDS)
baseurl=http://10.0.3.163/epel
path=/
enabled=1
gpgcheck=0
