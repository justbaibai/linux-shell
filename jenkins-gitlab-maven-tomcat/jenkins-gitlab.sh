Deploy Keys
可以拉不可以推 enable
两个项目以上
settings - repository-deploy keys 在privately点enable

如果是内网的话vim /etc/sysconfig/jenkins用root
要不然就Jenkins-凭据-系统-全局凭据 (unrestricted) 选ssh私钥

不改就用http的 在gitlab上的账号有权限就行

做免密要  之后执行shell  就ok了

备份jekins
tar zcvf jenkins.tar.gz /var/lib/jenkins/

插件：安版本发布  git parameter plugin
一般上选着 git parameter
Branches to build
在源码管理上选${Tag}

触发远程构建 (例如,使用脚本)  里的 在gitlab里的hook也填一样的
插件：Build Authorization Token Root
插件：gitlab
Build when a change is pushed to GitLab. GitLab webhook URL: http://10.0.3.12:8080/project/baibai_frist
webhook
http：//ip/buildByToken/build?job=baibai_frist&token=XXXX
GitLab： System Hooks
jenkins：触发远程构建 (例如,使用脚本) Build when a change is pushed to GitLab. GitLab webhook URL: http://10.0.3.12:8080/project/baibai_frist
选上面这两个


java
yum install -y maven
mvn -version

Maven Integration plugin
SSH plugin
Pulish Over SSH
在configure里面配置
hosname 写ip


调用顶端maven目标
maven3
clean package

执行shell
case $Status in
	Deploy)
    	scp  target/*war tomcat@10.0.3.14:/usr/local/tomcat/webapps/
        ;;
	RollBack)
       echo "test"
       ;;
	*)
    exit
    	;;
esac

Execute shell scrip
chown -R  tomcat:tomcat  /usr/local/tomcat/webapps/*
sh /home/tomcat/tomcat_start.sh restart







tomcat 启动慢
vim /usr/lib/jvm/jre-1.8.0-openjdk-1.8.0.222.b10-0.el7_6.x86_64/lib/security/java.security
有两种解决办法：

1）在Tomcat环境中解决

可以通过配置JRE使用非阻塞的Entropy Source。

在catalina.sh中加入这么一行：

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




Jenkins使用Git SCM的时候有一项源码库浏览器的设置，起初不知道有何用，只是看了说明大概知道是会对每次build生成changes，然后并没有告诉怎么设置，选择一种浏览器后要填一个URL，然后就各种百度谷歌没找到答案
