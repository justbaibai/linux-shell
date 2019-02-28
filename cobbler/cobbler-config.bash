#关闭selinux，和firewalld   look  http://cobbler.github.io/manuals/quickstart/

curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum makecache
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
yum install cobbler  pykickstart httpd dhcp tftp-server -y
#cobbler               #cobbler程序包
#cobbler-web                #cobbler的web服务包
#pykickstart              #cobbler检查kickstart语法错误
#httpd                 #Apache web服务
#dhcp                 #dhcp服务
#tftp-server              #tftp服务


#systemctl start cobbler
systemctl start cobblerd
systemctl start httpd
#httpd: Could not reliably determine the server's fully qualified domain name, using 127.0.0.1 for ServerName
vim /etc/httpd/conf/httpd.conf #添加以下一行
ServerName localhost:80

cobbler check  #检查一下

#1 : The 'server' field in /etc/cobbler/settings must be set to something other than localhost, or kickstarting features will not work.  This should be a resolvable hostname or IP for the boot server as reachable by all machines that will use it.
#2 : For PXE to be functional, the 'next_server' field in /etc/cobbler/settings must be set to something other than 127.0.0.1, and should match the IP of the boot server on the PXE network.
#3 : SELinux is enabled. Please review the following wiki page for details on ensuring cobbler works correctly in your SELinux environment:
    https://github.com/cobbler/cobbler/wiki/Selinux
#4 : change 'disable' to 'no' in /etc/xinetd.d/tftp
#5 : Some network boot-loaders are missing from /var/lib/cobbler/loaders, you may run 'cobbler get-loaders' to download them, or, if you only want to handle x86/x86_64 netbooting, you may ensure that you have installed a *recent* version of the syslinux package installed and can ignore this message entirely.  Files in this directory, should you want to support all architectures, should include pxelinux.0, menu.c32, elilo.efi, and yaboot. The 'cobbler get-loaders' command is the easiest way to resolve these requirements.
#6 : enable and start rsyncd.service with systemctl
#7 : debmirror package is not installed, it will be required to manage debian deployments and repositories
#8 : The default password used by the sample templates for newly installed machines (default_password_crypted in /etc/cobbler/settings) is still set to 'cobbler' and should be changed, try: "openssl passwd -1 -salt 'random-phrase-here' 'your-password-here'" to generate new one
#9 : fencing tools were not found, and are required to use the (optional) power management features. install cman or fence-agents to use them

#3，6,7,9可以不用管，rsyncd 开机自启动  其实它已经开着那   selinux  用getenforce 看一眼  yum install -y  debmirror   这个是deb的系统  yum install -y cman ence-agents 管理工具    

cp /etc/cobbler/settings{,.ori}  # 备份


 openssl passwd -1 -salt 'cobbler' '123456'
$1$cobbler$sqDDOBeLKJVmxTCZr52/11
 vim /etc/cobbler/settings 
default_password_crypted: "$1$cobbler$sqDDOBeLKJVmxTCZr52/11"
#sed -i 's#\$1\$mF86\/11WvcIcX2t6crBz2onWxyac\.#\$1\$cobbler\$sqDDOBeLKJVmxTCZr52\/11#g' /etc/cobbler/settings 

# server，Cobbler服务器的IP。
sed -i 's/server: 127.0.0.1/server: 10.0.0.7/' /etc/cobbler/settings
# next_server，如果用Cobbler管理DHCP，修改本项，作用不解释，看kickstart。
sed -i 's/next_server: 127.0.0.1/next_server: 10.0.0.7/' /etc/cobbler/settings
# 用Cobbler管理DHCP
sed -i 's/manage_dhcp: 0/manage_dhcp: 1/' /etc/cobbler/settings
# 防止循环装系统，适用于服务器第一启动项是PXE启动。
sed -i 's/pxe_just_once: 0/pxe_just_once: 1/' /etc/cobbler/settings
cobbler get-loaders  # 会自动从官网下载
 cd /var/lib/cobbler/loaders/  # 下载的内容
 ls
COPYING.elilo     COPYING.yaboot  grub-x86_64.efi  menu.c32    README
COPYING.syslinux  elilo-ia64.efi  grub-x86.efi     pxelinux.0  yaboot
 vi /etc/xinetd.d/tftp
 'disable' 的yes改成 'no' 
 #sed -i 's#\tdisable\t\t\t= yes#\tdisable\t\t\t= no#g' /etc/xinetd.d/tftp
 systemctl start tftp.socket
 systemctl start tftp.service
 systemctl start cobbler
systemctl start httpd

cobbler check


# 修改cobbler的dhcp模版，不要直接修改dhcp本身的配置文件，因为cobbler会覆盖。
 vim /etc/cobbler/dhcp.template 
# 仅列出修改过的字段

#subnet 10.0.3.0 netmask 255.255.255.0 {
     #option routers             10.0.3.1;
     #option domain-name-servers 10.0.3.1;
     #option subnet-mask         255.255.255.0;
     #range dynamic-bootp        10.0.3.160 10.0.3.165;
     
sed -i 's#192\.168\.1\.0#10\.0\.3\.0#g' /etc/cobbler/dhcp.template
sed -i 's#192\.168\.1\.5#10\.0\.3\.1#g' /etc/cobbler/dhcp.template
sed -i 's#192\.168\.1\.1#10\.0\.3\.1#g' /etc/cobbler/dhcp.template
sed -i 's#192\.168\.1\.100#10\.0\.3\.160#g' /etc/cobbler/dhcp.template
sed -i 's#192\.168\.1\.254#10\.0\.3\.168#g' /etc/cobbler/dhcp.template


# 同步最新cobbler配置，它会根据配置自动修改dhcp等服务。
 cobbler sync   # 同步所有配置，可以仔细看一下sync做了什么。
 #挂载镜像并导入镜像
 
 mount /dev/cdrom /mnt
cobbler import --path=/mnt/ --name=CentOS-6.9-x86_64 --arch=x86_64

# --path 镜像路径

# --name 为安装源定义一个名字

# --arch 指定安装源是32位、64位、ia64, 目前支持的选项有: x86│x86_64│ia64

# 安装源的唯一标示就是根据name参数来定义，本例导入成功后，安装源的唯一标示就是：CentOS-6.9-x86_64，如果重复，系统会提示导入失败。


#查看镜像列表

 cobbler distro list
  CentOS-6.9-x86_64


#镜像存放目录，cobbler会将镜像中的所有安装文件自动拷贝到本地一份，放在/var/www/cobbler/ks_mirror下的CentOS-6.9-x86_64目录下。因此/var/www/cobbler目录必须具有足够容纳安装文件的空间。

 ls /var/www/cobbler/ks_mirror/CentOS-6.9-x86_64/
CentOS_BuildTag  EULA  images    Packages                  repodata              RPM-GPG-KEY-CentOS-Debug-6     RPM-GPG-KEY-CentOS-Testing-6
EFI              GPL   isolinux  RELEASE-NOTES-en-US.html  RPM-GPG-KEY-CentOS-6  RPM-GPG-KEY-CentOS-Security-6  TRANS.TBL
#在第一次导入系统镜像后，Cobbler会给镜像指定一个默认的kickstart自动安装文件在/var/lib/cobbler/kickstarts下的sample_end.ks

#查看列表信息

cobbler list    
distros:
   CentOS-6.9-x86_64
profiles:
   CentOS-6.9-x86_64
systems:
repos:
images:
mgmtclasses:
packages:
files:


#查看安装镜像文件信息


 cobbler profile report -name=CentOS-6.9-x86_64  
Name                           : CentOS-6.9-x86_64
TFTP Boot Files                : {}
Comment                        : 
DHCP Tag                       : default
Distribution                   : CentOS-6.9-x86_64
Enable gPXE?                   : 0
Enable PXE Menu?               : 1
Fetchable Files                : {}
Kernel Options                 : {}
Kernel Options (Post Install)  : {}
Kickstart                      : /var/lib/cobbler/kickstarts/sample_end.ks


#编辑profile，修改关联的ks文件

 cobbler profile edit --name=CentOS-6.9-x86_64 --kickstart=/var/lib/cobbler/kickstarts/CentOS-6.9-x86_64.cfg
#可以看到下面Kickstart那里的配置cfg文件地址被改变了


cobbler profile report --name=CentOS-6.9-x86_64             
Name                           : CentOS-6.9-x86_64
TFTP Boot Files                : {}
Comment                        : 
DHCP Tag                       : default
Distribution                   : CentOS-6.9-x86_64
Enable gPXE?                   : 0
Enable PXE Menu?               : 1
Fetchable Files                : {}
Kernel Options                 : {}
Kernel Options (Post Install)  : {}
Kickstart                      : /var/lib/cobbler/kickstarts/CentOS-6.9-x86_64.cfg


#同步下cobbler数据，每次修改完都要镜像同步
 cobbler sync


#最后一步，看个人意愿，开机画面显示
 vim /etc/cobbler/pxe/pxedefault.template 
MENU TITLE Cobbler | Welcome to Cobbler
#我安装了7.4,6.9，两个版本  
#查看安装镜像文件信息
 cobbler distro report --name=CentOS-7.4-x86_64
 #centos7 的eth0
 
 cobbler profile edit --name=CentOS-7.1-x86_64 --kopts='net.ifnames=0 biosdevname=0'
 cobbler profile report CentOS-7.4-x86_64
 
 



 
 
	 
	 


