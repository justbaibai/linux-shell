#!/bin/sh
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -P /usr/local/src https://download.oracle.com/otn-pub/java/jdk/8u191-b12/2787e4a523244c269598db4e85c51e0c/jdk-8u191-linux-x64.tar.gz
cd /usr/local/src && tar xf jdk-8u191-linux-x64.tar.gz
mv /usr/local/src/jdk1.8.0_191 /usr/local/jdk1.8.0_191
ln -s /usr/local/jdk1.8.0_191/ /usr/local/jdk

echo "#!/bin/bash
JAVA_HOME=/usr/local/jdk
JRE_HOME=/usr/local/jdk/jre
PATH=\$PATH:\$JAVA_HOME/bin
CLASSPATH=\$JAVA_HOME/jre/lib/ext:\$JAVA_HOME/lib/tools.jar
export JAVA_HOME JRE_HOME PATH CLASSPATH

" >> /etc/profile.d/jdk.sh
#chmod a+x /etc/profile.d/jdk.sh
source /etc/profile.d/jdk.sh
