#!/bin/sh
yum install -y rsync
useradd -s /sbin/nologin -M rsync
mkdir /backup
chown -R rsync.rsync /backup/
echo "
uid = rsync
gid = rsync
use chroot = no
max connections = 200
timeout = 300
pid file = /var/run/rsyncd.pid
lock file = /var/run/rsync.lock
log file = /var/log/rsyncd.log
ignore errors
read only = false
list = false
hosts allow = 10.0.3.0/24
hosts deny = 0.0.0.0/32
auth users = baibai
secrets file = /etc/rsync.password
[backup]
comment = "this is for test "
path = /backup" >/etc/rsyncd.conf
echo "baibai:baibai" > /etc/rsync.password
chmod 600 /etc/rsyncd.conf
chmod 600 /etc/rsync.password
rsync --daemon
#cat /var/run/rsyncd.pid | xargs kill -9
#pkill rsync

#服务端26  客户端40  下面的命令在客户端执行 把客户端的、/etc/hosts 推到服务端的back/下
#rsync -avz /etc/hosts baibai@10.0.3.26::backup --password-file=/etc/rsync.password 从客户端推到服务端
#rsync -avz  baibai@10.0.3.26::backup /t --password-file=/etc/rsync.password 把服务端的内容拉到本地
#利用rsync客户端同步数据（非常重要）
#	rsync -avz /tmp/ rsync_backup@172.16.1.41::backup/ --password-file=/etc/rsync.password 
#	说明：/tmp/ 表示同步tmp目录下内容，但不包含目录本身
#	rsync -avz /tmp rsync_backup@172.16.1.41::backup/ --password-file=/etc/rsync.password 
#	说明：/tmp 表示同步tmp目录下内容及目录本身



#客户端只要密码 用户：密码
#echo "baibai" > /etc/rsync.password
#chmod 600 /etc/rsync.password

#Pull: rsync [OPTION...] [USER@]HOST::SRC... [DEST]
#Push: rsync [OPTION...] SRC... [USER@]HOST::DEST
