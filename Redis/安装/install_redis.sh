#!/bin/sh
wget http://download.redis.io/releases/redis-5.0.4.tar.gz -P /usr/local/
cd /usr/local/
tar xf redis-5.0.4.tar.gz
make
make install PREFIX=/usr/local/redis
#或者带版本号ln -s  软连接
#这个以后升级的时候只要修改软连接的指向就行了
#或者直接用
cd src/

cp /usr/local/redis-5.0.4/redis.conf /usr/local/redis/bin/
/usr/local/redis/bin/redis-server /usr/local/redis/bin/redis.conf
 /usr/local/redis/bin/redis-cli -h 10.0.3.118
 auth baibai
 /usr/local/redis/bin/redis-cli -h 10.0.3.118 -a baibai shutdown
