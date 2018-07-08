#Cobbler是一个Linux服务器快速网络安装的服务，而且在经过调整也可以支持网络安装windows。

#该工具使用python开发，可以通过网络启动(PXE)的方式来快速安装、重装物理服务器和虚拟机，同时还可以管理DHCP，DNS，TFTP、RSYNC以及yum仓库、构造系统ISO镜像。

#Cobbler可以使用命令行方式管理，也提供了基于Web的界面管理工具(cobbler-web)，还提供了API接口，可以方便二次开发使用。

#Cobbler是较早前的kickstart的升级版，优点是比较容易配置，还自带web界面比较易于管理。

#Cobbler用处

#使用Cobbler，您无需进行人工干预即可安装机器。Cobbler设置一个PXE引导环境（它还可以使用yaboot支持PowerPC），并 控制与安装相关的所有方面，比如网络引导服务（DHCP和TFTP）与存储库镜像。当希望安装一台新机器时，Cobbler可以：

#1）使用一个以前定义的模板来配置DHCP服务（如果启用了管理DHCP）。

#2）将一个存储库（yum或rsync）建立镜像或解压缩一个媒介，以注册一个新操作系统。

#3）在DHCP配置文件中为需要安装的机器创建一个条目，并使用指定的参数（IP和MAC）。

#4）在TFTP服务目录下创建适当的PXE文件。

#5）重新启动DHCP服务来反应新的更改。

#6）重新启动机器以开始安装（如果电源管理已启动）。

#http://cobbler.github.io/   官方网站

#最好在centos7 上安装   centos6上  cobbler-web yum 不上   python2.6 的。。。自己去踩吧。