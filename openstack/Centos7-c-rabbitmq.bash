#!/bin/sh

#RabbitMQ #消息队列
yum -y install erlang socat rabbitmq-server >/dev/null 2>&1

if [ $? -eq 0 ]; then
	echo " rabbitmq is ok"
else
	exho "rabbitmq is not ok"
fi
#启动 rabbitmq ,端口5672
systemctl enable rabbitmq-server.service >/dev/null 2>&1
systemctl start rabbitmq-server.service >/dev/null 2>&1
rabbitmq-plugins enable rabbitmq_management  >/dev/null 2>&1  #启动web插件端口15672
if [ $? -eq 0 ]; then
	echo "rabbitmq-plugins is ok"
else 
	echo "rabbitmq-plugins is not ok"
sleep 5s
fi


#添加用户及密码
#rabbitmqctl  add_user admin admin
#rabbitmqctl  set_user_tags admin administrator
rabbitmqctl add_user openstack openstack 
rabbitmqctl set_permissions openstack ".*" ".*" ".*" 
rabbitmqctl  set_user_tags openstack administrator
systemctl restart rabbitmq-server.service  >/dev/null 2>&1
netstat -antp|grep '5672'

sleep 5s

echo "http://10.0.3.111:15672 is ok or not ok"

# rabbitmq-plugins list  #查看支持的插件
# lsof -i:15672
#访问RabbitMQ,访问地址是http://ip:15672
#默认用户名密码都是guest，浏览器添加openstack用户到组并登陆测试

# #------------------