echo never >>  /sys/kernel/mm/transparent_hugepage/enabled
echo never >>  /sys/kernel/mm/transparent_hugepage/defrag
cat /sys/kernel/mm/transparent_hugepage/enabled
cat /sys/kernel/mm/transparent_hugepage/defrag
wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.6.14.tgz --no-check-certificate
tar xf mongodb-linux-x86_64-3.6.14.tgz
mkdir -p /mongodb/conf  /mongodb/log /mongodb/data
useradd mongodb
passwd mongodb
cp -r /usr/local/src/mongodb-linux-x86_64-3.6.14/bin /mongodb
chown -R mongodb.mongodb /mongodb
su - mongodb

echo 'export PATH=$PATH:/mongodb/bin' >>.bash_profile
source  .bash_profile

echo 'export PATH=$PATH:/mongodb/bin' >>/etc/profile
source  /etc/profile

##  都可以

vim /mongodb/conf/mongod.conf
systemLog:
   destination: file
   path: "/mongodb/log/mongod.log"
   logAppend: true
storage:
   journal:
      enabled: true
   dbPath: "/mongodb/data"
processManagement:
   fork: true
net:
   bindIp: 127.0.0.1,10.0.3.208
   port: 27017
setParameter:
   enableLocalhostAuthBypass: false
security:
   authorization: enabled

mongod -f /mongodb/conf/mongod.conf   --shutdown
mongo -uroot -p ip/库名

ps -ef | grep mongod
cat /proc/13974/limits

 vi /etc/security/limits.conf
mongod soft nofile 64000
mongod hard nofile 64000
mongod soft nproc 32000
mongod hard nproc 32000
#上面修改完还waring  改下面
vim  /etc/security/limits.d/90-nproc.conf
* soft nproc 64000


use admin
db.createUser(
{
    user: "baibai",
    pwd: "baibai",
    roles: [{ role: "root", db: "admin"}]
}
)




生产配置
systemLog:
   destination: file
   path: "/mongodb/log/mongod.log"
   logAppend: true
storage:
   journal:
      enabled: true
   dbPath: "/mongodb/data"
   directoryPerDB: true
   wiredTiger:
     engineConfig:
       cacheSizeGB: 1
       directoryForIndexes: true
     collectionConfig:
       blockCompressor: zlib
     indexConfig:
       prefixCompression: true
processManagement:
   fork: true
net:
   bindIp: 127.0.0.1,10.0.3.208
   port: 27017
replication:
  oplogSizeMB: 2048
  replSetName: my_repl
setParameter:
   enableLocalhostAuthBypass: false
security:
   authorization: enabled




admin库
config = {_id: "my_repl", members:[
                          {_id: 0, host: '你自己的ip'},
                          {_id: 0, host: '你自己的ip'}
]}
rs.initiate(config)

rs.status();
