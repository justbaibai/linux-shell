#!/bin/sh
yum install memcached python-memcached -y >/dev/null 2>&1
if [ $? -eq 0 ]; then
	echo "memcached install is ok"
else
	echo "memcached install is not ok"
fi
sleep 5s
sed -i "s#127.0.0.1,::1#127.0.0.1,::1,baibaic#g" /etc/sysconfig/memcached

cp /etc/sysconfig/memcached{,.bak}

systemctl enable memcached.service >/dev/null 2>&1
systemctl start memcached.service >/dev/null 2>&1
if [ $? -eq 0 ]; then
	echo "service is ok"
else
	echo "service is not ok"
fi

netstat -utpnl|grep memcache
echo "if have 11211 port memcache is ok"
