#!/bin/sh
wget -P /usr/local/src http://mirror.bit.edu.cn/apache/tomcat/tomcat-8/v8.5.45/bin/apache-tomcat-8.5.45.tar.gz
cd /usr/local/src && tar xf apache-tomcat-8.5.43.tar.gz
mv  /usr/local/src/apache-tomcat-8.5.43 /usr/local/apache-tomcat-8.5.43
ln -s /usr/local/apache-tomcat-8.5.43/ /usr/local/tomcat
echo "
#!/bin/sh
PATH=\$PATH:/usr/local/tomcat/bin
">>/etc/profile.d/tomcat.sh

source /etc/profile.d/tomcat.sh

