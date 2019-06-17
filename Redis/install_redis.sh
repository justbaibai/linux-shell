#!/bin/sh
wget http://download.redis.io/releases/redis-5.0.4.tar.gz -P /usr/local/
cd /usr/local/
tar xf redis-5.0.4.tar.gz
make
make install PREFIX=/usr/local/redis
或者直接用
cd src/

cp /usr/local/redis-5.0.4/redis.conf /usr/local/redis/bin/
/usr/local/redis/bin/redis-server /usr/local/redis/bin/redis.conf
 /usr/local/redis/bin/redis-cli -h 10.0.3.118
 auth baibai
 /usr/local/redis/bin/redis-cli -h 10.0.3.118 -a baibai shutdown



现在redis的漏洞比较多，大多数就是因为密码太简单导致的，所以把redis密码改一下，在redis.conf里，建议改成如下的样子：

bind 内网IP地址 127.0.0.1  10.0.3.118               ###仅允许内网和本机访问
protected-mode yes                   ###保护模式开启
port 6379                          ###端口默认为6379，按需修改
daemonize yes                        ###守护模式开启
pidfile /usr/local/redis/redis.pid               ###指定pid文件路径和文件名
logfile "/usr/local/redis/redis.log"             ###指定日志文件路径和文件名
dbfilename redis.rdb                     ###指定数据文件RDB文件名
dir /usr/local/redis/                    ###指定数据文件RDB文件的存放路径
requirepass 『YOURPASSWORD』              ###设置访问密码，提升密码强度
