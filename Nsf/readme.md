客户端 和服务端
#管理
showmount -e  localhost #显示共享信息
exportfs -ar  #重新加载exprots文件，使新的挂载参数生效

cat /var/lib/nfs/etab  



#客户端同样需要启动portmap,centos6之后是rpcbind

yum install -y  rpcbind nfs-utils
# nfs-utils 可以不安装  showmount用不了
service  (portmap|rpcbind)  start

#showmount -e (ip)  #扫描服务器共享信息

#挂载服务器共享目录到本地，挂载参数可控
#mount -t nfs -o rw,ro,bg,fg,nosuid,nodev,noexec,soft,hard,intr,rsize=,wsize=  10.0.3.26:/data  /baibai
#mount -t nfs -o nosuid,noexec,nodev,noatime,nodiratime,rsize=131072,wsize=131072 172.16.1.31:/data/ /upload #优化参数
mkdir baibai
mount -t nfs 10.0.3.26:/data  /baibai
#cat /proc/mounts 查看挂载参数
#autofs自动挂载
#主要配置文件 auto.master
#vi  /etc/auto.master
##/home   /etc/auto.nfs  #auto.nfs文件名为自定义

#具体配置文件 auto.nfs
#vi  /etc/auto.nfs

#public  -rw,bg,soft,rsize=2048,wsize=2048  10.0.8.2:/data/pub
#software  -ro,bg,soft,rsize=2048,wsize=2048  10.0.8.2:/data/software
#……
#当试图读取本机的/home/public目录时，本机就会自动去挂载10.0.8.2上的/data/public目录，挂载的参数就是以"-"开头的那几个参数。而超过一定时间不使用，系统又会自动卸载这个远程挂载。

#service autofs start


umount.nfs -fl /baibai
网不好  的  客户端卡主
mount -t nfs  -o soft,intr,timeo=30,retry=3   10.0.3.26:/data  /baibai

A）访问权限

ro：设置输出目录只读。

rw：设置输出目录读写。

B）用户映射

root_squash：将root用户映射为来宾账号（nfsnoboydy用户），默认启用。

no_root_squash：不映射客户端root账号为来宾账号，也就意味着客户端root具有服务端root的用户权限。

all_squash：将远程访问的所有普通用户及所属组都映射为匿名用户或用户组（nfsnobody）。

no_all_squash：与all_squash取反（默认设置）；

anonuid=501：指定映射的账号UID。

anongid=501：指定映射的账号GID。

C）其他

secure：限制客户端只能从小于1024的tcp/ip端口连接nfs服务器（默认设置）。

insecure：允许客户端从大于1024的tcp/ip端口连接服务器。

sync：将数据同步写入内存缓冲区与磁盘中，效率低，但可以保证数据的一致性。

async：将数据先保存在内存缓冲区中，必要时才写入磁盘，默认使用。

wdelay：检查是否有相关的写操作，如果有则将这些写操作一起执行，这样可以提高效率（默认设置）。

no_wdelay：若有写操作则立即执行，应与sync配合使用。

subtree：若输出目录是一个子目录，则nfs服务器将检查其父目录的权限(默认设置)。

no_subtree：即使输出目录是一个子目录，nfs服务器也不检查其父目录的权限，这样可以提高效率。


挂载的参数
suid与nosuid:开放或取消SUID功能,默认为suid
rw,ro:指定可读写或只读,默认为rw
dev,nodev:是否可以保留装置文件的特殊功能,默认为dev
exec,noexec:是否具有可执行权限,默认为exec
user,nouser:是否具有进行挂载与卸载的功能,默认为nouser
auto,noauto:指mount-a时会不会被挂载的项目,如不需要可设为noauto,默认为auto

fg,bg:前台执行或后台执行,默认为fg
soft,hard:是否在挂载时持续呼叫,默认为hard,建议用soft
intr:加上它,若使用hard方式时,RPC呼叫可以被中断
rsize,wsize:写缓冲区与读缓冲区,可提高性能,很重要
