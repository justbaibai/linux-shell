nginx +2tomcat+redis  会话存储
yum install java-1.8.0-openjdk -y

source /etc/profile.d/jdk.sh
JAVA_HOME=/usr/lib/jvm
JRE_HOME=/usr/lib/jvm/jre-1.8.0-openjdk-1.8.0.212.b04-0.el7_6.x86_64
PATH=$PATH:$JAVA_HOME/bin
CLASS_PATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export JAVA_HOME JRE_HOME PATH CLASSPATH


javac -vetsion
 yum install -y java-1.8.0-openjdk-devel.x86_64

 [root@localhost ~]# java -version
openjdk version "1.8.0_212"
OpenJDK Runtime Environment (build 1.8.0_212-b04)
OpenJDK 64-Bit Server VM (build 25.212-b04, mixed mode)


参考redis安装
redis 安装gcc
zmalloc.h:50:31: fatal error: jemalloc/jemalloc.h: No such file or directory
 #include <jemalloc/jemalloc.h>

make MALLOC=libc
 日志级别改一下

主要通过以下的几个jvm参数来设置堆内存的：


参考tomcat安装
-Xmx512m	最大总堆内存，一般设置为物理内存的1/4
-Xms512m	初始总堆内存，一般将它设置的和最大堆内存一样大，这样就不需要根据当前堆使用情况而调整堆的大小了
-Xmn192m	年轻带堆内存，sun官方推荐为整个堆的3/8
堆内存的组成	总堆内存 = 年轻带堆内存 + 年老带堆内存 + 持久带堆内存
年轻带堆内存	对象刚创建出来时放在这里
年老带堆内存	对象在被真正会回收之前会先放在这里
持久带堆内存	class文件，元数据等放在这里
-XX:PermSize=128m	持久带堆的初始大小
-XX:MaxPermSize=128m	持久带堆的最大大小，eclipse默认为256m。如果要编译jdk这种，一定要把这个设的很大，因为它的类太多了。

参考nginx安装
nginx
upstream baibai {
server 10.0.3.96:8080 max_fails=1 fail_timeout=10s;
server 10.0.3.97:8080 max_fails=1 fail_timeout=10s;
}
server {
    listen       80;
    server_name  localhost;

    #charset koi8-r;

    #access_log  logs/host.access.log  main;

    location / {
        proxy_pass http://baibai;
        root   html;
        index  index.html index.htm;
    }


tomcat1/webapps/新建目录,目录下新建index.jsp，内容如下
<%@ page language="java" %>
<html>
  <head><title>tomcat1</title></head>
  <body>
    <table align="centre" border="1">
      <tr>
        <td>SessionID</td>
        <td><%= session.getId() %></td>
      </tr>
      <tr>
        <td>SessionCreatedTime</td>
        <td><%= session.getCreationTime() %></td>
     </tr>
     <tr>
        <td>ServerName</td>
        <td><%=request.getServerName()%></td>
     </tr>
     <tr>
        <td>SessionPort</td>
        <td><%=request.getServerPort()%></td>
     </tr>
      <tr>
        <td>CustomString</td>
        <td>This is the first tomcat</td>
     </tr>
    </table>
  </body>
</html>

2把tomcat2改成1




二、session共享和负载均衡配置
https://github.com/redisson/redisson/wiki/2.-%E9%85%8D%E7%BD%AE%E6%96%B9%E6%B3%95
1、tocmat配置

1.1、在tomcat/conf/context.xml中增加RedissonSessionManager，tomcat1和tomcat2都要配置
<Manager className="org.redisson.tomcat.RedissonSessionManager" configPath="${catalina.base}/redisson.conf" readMode="MEMORY" updateMode="DEFAULT"/>

在tomcat安装目录下新建redisson.conf,添加如下配置
{
   "singleServerConfig":{
      "idleConnectionTimeout":10000,
      "pingTimeout":1000,
      "connectTimeout":10000,
      "timeout":3000,
      "retryAttempts":3,
      "retryInterval":1500,
      "password":"baibai",
      "subscriptionsPerConnection":5,
      "clientName":null,
      "address": "redis://10.0.3.98:6379",
      "subscriptionConnectionMinimumIdleSize":1,
      "subscriptionConnectionPoolSize":50,
      "connectionMinimumIdleSize":32,
      "connectionPoolSize":64,
      "database":0,
      "dnsMonitoringInterval":5000
   },
   "threads":0,
   "nettyThreads":0,
   "codec":{
      "class":"org.redisson.codec.JsonJacksonCodec"
   },
   "transportMode":"NIO"
}

选着相应版本
https://github.com/redisson/redisson/tree/master/redisson-tomcat
wget https://repository.sonatype.org/service/local/artifact/maven/redirect?r=central-proxy&g=org.redisson&a=redisson-all&v=3.11.1&e=jar
wget https://repository.sonatype.org/service/local/artifact/maven/redirect?r=central-proxy&g=org.redisson&a=redisson-tomcat-8&v=3.11.1&e=jar
拷贝到tomcat/lib下
