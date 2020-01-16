#!/bin/sh
wget -P /usr/local/src http://mirror.bit.edu.cn/apache/tomcat/tomcat-8/v8.5.50/bin/apache-tomcat-8.5.50.tar.gz
cd /usr/local/src && tar xf apache-tomcat-8.5.50.tar.gz
mv  /usr/local/src/apache-tomcat-8.5.50 /usr/local/apache-tomcat-8.5.50
ln -s /usr/local/apache-tomcat-8.5.50/ /usr/local/tomcat
echo "
#!/bin/sh
PATH=\$PATH:/usr/local/tomcat/bin
">>/etc/profile.d/tomcat.sh

useradd tomcat
passwd tomcat
chown -R tomcat.tomcat /usr/local/apache-tomcat-8.5.50
source /etc/profile.d/tomcat.sh

