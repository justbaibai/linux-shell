#!/bin/sh
echo TZ\='Asia/Shanghai'\; export TZ >> ~/.bash\_profile && source ~/.bash\_profile
yum install gcc libffi-devel python-devel openssl-devel libpcap-devel git -y
wget https://sec.ly.com/mirror/get-pip.py --no-check-certificate
python get-pip.py
pip install -U pip
git clone
cd
pip install -r requirements.txt -i https://pypi.doubanio.com/simple/
echo "
[mongodb-org]
name=MongoDB Repository
baseurl=http://mirrors.aliyun.com/mongodb/yum/redhat/7Server/mongodb-org/3.2/x86_64/
gpgcheck=0
enabled=1
">>/etc/yum.repos.d/mongodb-org-3.2.repo
yum install -y mongodb-org
#netstat -antlp | grep 27017
# systemctl start mongod
#service mongod restart
mongo
> use xunfeng
> db.createUser({user:'admin',pwd:'admin',roles:[{role:'dbOwner',db:'xunfeng'}]})
> exit
cd db
mongorestore -h 127.0.0.1 --port 27017 -d xunfeng .
service mongod stop
修改系统数据库配置脚本 Config.py:

class Config(object):
    ACCOUNT = 'admin'
    PASSWORD = 'admin'
修改 PASSWORD 字段内的密码, 设置成你的密码。

class ProductionConfig(Config):
    DB = '127.0.0.1'
    PORT = 27017
    DBUSERNAME = 'admin'
    DBPASSWORD = 'admin'
    DBNAME = 'xunfeng'
    1.在Centos7下 yum安装mongo后，查看 /etc/mongod.conf 默认db的路径的 /var/lib/mongo 而Run.sh 中定义的路径为 /var/lib/mongodb 导致启动后无法认证通过，修改该路径即可
    把run.sh 改成/var/lib/mongo
    2. 推送的插件：SHIRO 反序列化漏洞 安装失败：pip install cryptography
    安装cryptography后插件成功安装。
    sh Run.sh
