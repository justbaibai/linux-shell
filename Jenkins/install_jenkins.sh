#!/bin/sh
yum install -y java-1.8.0-openjdk wget
wget -O  /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo  && rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key &&yum clean all && yum makecache && yum install -y jenkins && systemctl start jenkins
 wget https://mirrors.tuna.tsinghua.edu.cn/jenkins/redhat-stable/jenkins-2.150.1-1.1.noarch.rpm
 #我用清华大学的源了  不知道官网为毛打不开  可能我人品不行   万能的长城防火前
 yum localinstall -y jenkins-2.150.1-1.1.noarch.rpm
systemctl start jenkins
cat /var/lib/jenkins/secrets/initialAdminPassword
#安装目录/var/lib/jenkins
#配置文件 /etc/sysconfig/jenkins
#日志目录 /var/log/jenkins
jenkins This Jenkins instance appears to be offline.
先找到配置，再将https的修改为http
vim /var/lib/jenkins/hudson.model.UpdateCenter.xml
/jenkins/pluginManager/advanced/
http://updates.jenkins-ci.org/download/plugins/
或换成这个https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/stable/update-center.json

相关配置

# Jenkins安装目录

/var/lib/jenkins

# Jenkins配置文件地址

cat /etc/sysconfig/jenkins

# 三个比较重要的配置

JENKINS_HOME是Jenkins的主目录，Jenkins工作的目录都放在这里,Jenkins储存文件的地址,Jenkins的插件，生成的文件都在这个目录下。

JENKINS_USER是Jenkins的用户，拥有$JENKINS_HOME和/var/log/jenkins的权限。

JENKINS_PORTJENKINS_PORT是Jenkins的端口，默认端口是8080。

报错解决如下：

jenkins报错：Problem accessing /jenkins/. Reason: HTTP ERROR 404

这是一个Jenkins的Bug。临时解决方法是：在浏览器中手工输入：http://<ip>:<port>

不要访问"/jenkins"这个路径。

jenkins 报错： office This jenkins instance appears to be offline.

[root@caosm98 ~]# cat /var/lib/jenkins/hudson.model.UpdateCenter.xml

<?xml version='1.0' encoding='UTF-8'?>

<sites>

<site>

<id>default</id>

<url>http://updates.jenkins.io/update-center.json</url>

</site>

https 改成http

需要重启jenkins
1.停留在可选插件那个页面，不要关闭页面。



2.然后再打开一个新的窗口，输入网址http://localhost:8080/pluginManager/advanced，输入网址打开后滑动到页面下方，最底下有个【升级站点】，把其中的链接改成这个http的链接   http://updates.jenkins.io/update-center.json。

 


http://localhost:8080/pluginManager/advanced
https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/stable/update-center.json
