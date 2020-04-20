tomcat 启动慢
vim /usr/lib/jvm/jre-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64/lib/security/java.security
有两种解决办法：

1）在Tomcat环境中解决

可以通过配置JRE使用非阻塞的Entropy Source。

在catalina.sh中加入这么一行：
# In addition, if "file:/dev/random" or "file:/dev/urandom" is
# specified, the "NativePRNG" implementation will be more preferred than
# SHA1PRNG in the Sun provider.
#


JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom"
即可。

加入后再启动Tomcat，整个启动耗时迅速下降。

2）在JVM环境中解决

打开$JAVA_PATH/jre/lib/security/java.security这个文件，找到下面的内容：

securerandom.source=file:/dev/urandom
替换成

securerandom.source=file:/dev/./urandom


要让tomcat支持软连接，需要在tomcat配置文件conf/context.xml里追加allowLinking="true"（tomcat8开始配置有变），具体如下配置：





Tomcat 7的方案
修改 /conf/context.xml 文件，将这个：
<Context>

改为：
<Context allowLinking="true">

Tomcat 8&9的方案
同样是修改 /conf/context.xml 文件，在这个里面：
<Context>
    ...
</Context>

增加一行这个：
<Resources allowLinking="true"></Resources>

变成这样：
<Context>
    <Resources allowLinking="true"></Resources>
    ...
</Context>
