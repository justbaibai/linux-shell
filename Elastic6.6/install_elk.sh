#!/bin/sh
#https://wiki.shileizcc.com/confluence/display/ELK/ELK+Binary+Install+6.4.1
echo '
* hard nofile 65536
* soft nofile 65536
* soft nproc  65536
* hard nproc  65536
elasticsearch soft memlock unlimited
elasticsearch hard memlock unlimited
'>>/etc/security/limits.conf
echo '
vm.max_map_count = 262144
net.core.somaxconn=65535
#net.ipv4.ip_forward = 1
'>>/etc/sysctl.conf
sysctl -p

/etc/hosts
/etc/hostname
hostname
logout
yum install java-1.8.0-openjdk -y
wget -P /usr/local/src/ https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.6.1.rpm
wget -P /usr/local/src/ https://artifacts.elastic.co/downloads/kibana/kibana-6.6.1-x86_64.rpm
wget -P /usr/local/src/  https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-6.6.1-x86_64.rpm
wget -P /usr/local/src/ https://artifacts.elastic.co/downloads/logstash/logstash-6.6.1.rpm

yum localinstall elasticsearch-6.6.1.rpm -y
yum localinstall logstash-6.6.1.rpm -y
yum localinstall kibana-6.6.1-x86_64.rpm -y
yum localinstall filebeat-6.6.1-x86_64.rpm -y

yum install  redis -y


grep -v '^#' /etc/elasticsearch/elasticsearch.yml
cp /etc/elasticsearch/elasticsearch.yml{,.bak}

 #更改配置
echo '
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
cluster.name: ELK
node.name: elk.novalocal
network.host: 10.0.3.162
http.port: 9200
discovery.zen.ping.unicast.hosts: ["10.0.3.162","10.0.3.161"]
discovery.zen.minimum_master_nodes: 1
'>/etc/elasticsearch/elasticsearch.yml
 #修改配置后
 改成2G  但最大不能超过32G
 /etc/elasticsearch/jvm.options
systemctl daemon-reload
systemctl enable  elasticsearch
systemctl restart elasticsearch

错误
[1] bootstrap checks failed
[1]: memory locking requested for elasticsearch process but memory is not locked

/etc/elasticsearch/elasticsearch.yml
bootstrapb .memory_lock ： false

把
/etc/security/limits.conf
elasticsearch soft memlock unlimited
elasticsearch hard memlock unlimited

如果还是不行
vim /usr/lib/systemd/system/elasticsearch.service

LimitMEMLOCK=infinity

# Specifies the maximum file descriptor number that can be opened by this process
LimitNOFILE=65536

# Specifies the maximum number of processes

LimitNPROC=65535



/etc/sysconfig/elasticsearch


Specifies the maximum file descriptor number that can be opened by this process
# When using Systemd, this setting is ignored and the LimitNOFILE defined in
# /usr/lib/systemd/system/elasticsearch.service takes precedence
MAX_OPEN_FILES=65536

# The maximum number of bytes of memory that may be locked into RAM
# Set to "unlimited" if you use the 'bootstrap.memory_lock: true' option
# in elasticsearch.yml.
# When using systemd, LimitMEMLOCK must be set in a unit file such as
# /etc/systemd/system/elasticsearch.service.d/override.conf.
MAX_LOCKED_MEMORY=unlimited

# Maximum number of VMA (Virtual Memory Areas) a process can own
# When using Systemd, this setting is ignored and the 'vm.max_map_count'
# property is set at boot time in /usr/lib/sysctl.d/elasticsearch.conf
MAX_MAP_COUNT=262144



JAVA_HOME
Set a custom Java path to be used.

MAX_OPEN_FILES
Maximum number of open files, defaults to 65536.

MAX_LOCKED_MEMORY
Maximum locked memory size. Set to unlimited if you use the bootstrap.memory_lock option in elasticsearch.yml.

MAX_MAP_COUNT
Maximum number of memory map areas a process may have. If you use mmapfs as index store type, make sure this is set to a high value. For more information, check the linux kernel documentation about max_map_count. This is set via sysctl before starting Elasticsearch. Defaults to 262144.

ES_PATH_CONF
Configuration file directory (which needs to include elasticsearch.yml, jvm.options, and log4j2.properties files); defaults to /etc/elasticsearch.

ES_JAVA_OPTS
Any additional JVM system properties you may want to apply.

RESTART_ON_UPGRADE
Configure restart on package upgrade, defaults to false. This means you will have to restart your Elasticsearch instance after installing a package manually. The reason for this is to ensure, that upgrades in a cluster do not result in a continuous shard reallocation resulting in high network traffic and reducing the response times of your cluster.




 #check
systemctl status elasticsearch
netstat -nltp | grep java
curl -X GET http://localhost:9200




elasticsearch的config文件夹里面有两个配置文件：elasticsearch.yml和logging.yml，

第一个是es的基本配置文件，第二个是日志配置文件，es也是使用log4j来记录日志的，所以logging.yml里的设置按普通log4j配置文件来设置就行了。下面主要讲解下elasticsearch.yml这个文件中可配置的东西。
cluster.name:elasticsearch
配置es的集群名称，默认是elasticsearch，es会自动发现在同一网段下的es，如果在同一网段下有多个集群，就可以用这个属性来区分不同的集群。
node.name:”FranzKafka”
节点名，默认随机指定一个name列表中名字，该列表在es的jar包中config文件夹里name.txt文件中，其中有很多作者添加的有趣名字。
node.master:true
指定该节点是否有资格被选举成为node，默认是true，es是默认集群中的第一台机器为master，如果这台机挂了就会重新选举master。
node.data:true
指定该节点是否存储索引数据，默认为true。
index.number_of_shards:5
设置默认索引分片个数，默认为5片。
index.number_of_replicas:1
设置默认索引副本个数，默认为1个副本。
path.conf:/path/to/conf
设置配置文件的存储路径，默认是es根目录下的config文件夹。
path.data:/path/to/data
设置索引数据的存储路径，默认是es根目录下的data文件夹，可以设置多个存储路径，用逗号隔开，例：
path.data:/path/to/data1,/path/to/data2
path.work:/path/to/work
设置临时文件的存储路径，默认是es根目录下的work文件夹。
path.logs:/path/to/logs
设置日志文件的存储路径，默认是es根目录下的logs文件夹
path.plugins:/path/to/plugins
设置插件的存放路径，默认是es根目录下的plugins文件夹
bootstrap.mlockall:true
设置为true来锁住内存。因为当jvm开始swapping时es的效率会降低，所以要保证它不swap，可以把ES_MIN_MEM和ES_MAX_MEM两个环境变量设置成同一个值，并且保证机器有足够的内存分配给es。同时也要允许elasticsearch的进程可以锁住内存，linux下可以通过`ulimit-lunlimited`命令。
network.bind_host:192.168.0.1
设置绑定的ip地址，可以是ipv4或ipv6的，默认为0.0.0.0。network.publish_host:192.168.0.1
设置其它节点和该节点交互的ip地址，如果不设置它会自动判断，值必须是个真实的ip地址。
network.host:192.168.0.1
这个参数是用来同时设置bind_host和publish_host上面两个参数。
transport.tcp.port:9300
设置节点间交互的tcp端口，默认是9300。
transport.tcp.compress:true
设置是否压缩tcp传输时的数据，默认为false，不压缩。
http.port:9200
设置对外服务的http端口，默认为9200。
http.max_content_length:100mb
设置内容的最大容量，默认100mb
http.enabled:false
是否使用http协议对外提供服务，默认为true，开启。
gateway.type:local
gateway的类型，默认为local即为本地文件系统，可以设置为本地文件系统，分布式文件系统，hadoop的HDFS，和amazon的s3服务器，其它文件系统的设置方法下次再详细说。
gateway.recover_after_nodes:1
设置集群中N个节点启动时进行数据恢复，默认为1。
gateway.recover_after_time:5m
设置初始化数据恢复进程的超时时间，默认是5分钟。
gateway.expected_nodes:2
设置这个集群中节点的数量，默认为2，一旦这N个节点启动，就会立即进行数据恢复。
cluster.routing.allocation.node_initial_primaries_recoveries:4
初始化数据恢复时，并发恢复线程的个数，默认为4。
cluster.routing.allocation.node_concurrent_recoveries:2
添加删除节点或负载均衡时并发恢复线程的个数，默认为4。
indices.recovery.max_size_per_sec:0
设置数据恢复时限制的带宽，如入100mb，默认为0，即无限制。
indices.recovery.concurrent_streams:5
设置这个参数来限制从其它分片恢复数据时最大同时打开并发流的个数，默认为5。
discovery.zen.minimum_master_nodes:1
设置这个参数来保证集群中的节点可以知道其它N个有master资格的节点。默认为1，对于大的集群来说，可以设置大一点的值（2-4）
discovery.zen.ping.timeout:3s
设置集群中自动发现其它节点时ping连接超时时间，默认为3秒，对于比较差的网络环境可以高点的值来防止自动发现时出错。
discovery.zen.ping.multicast.enabled:false
设置是否打开多播发现节点，默认是true。
discovery.zen.ping.unicast.hosts:[“host1″,”host2:port”,”host3[portX-portY]”]
设置集群中master节点的初始列表，可以通过这些节点来自动发现新加入集群的节点




wget https://github.com/lmenezes/cerebro/releases/download/v0.8.1/cerebro-0.8.1.tgz
/usr/local/cerebro-0.8.1/bin
nohup nohup ./cerebro -Dhttp.port=1234 -Dhttp.address=10.0.3.161 &


index-demo/test
{
  "user": "baibai",
  "mesg": "hello word"
}
  systemctl start logstash
cp /etc/logstash/logstash.yml{,.bak}

echo 'path.config: /etc/logstash/conf.d'>>/etc/logstash/logstash.yml

/usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/nginx-accesslog.conf -t 测试配置文件是否正确



前台启动
cd /usr/share/logstash/bin/
./logstash -e 'input{stdin{}} output{stdout{}}'

配置文件启动
cd /etc/logstash/conf.d/
vim demo.conf

input{

    stdin{}


}



output{

elasticsearch{
	hosts => ["10.0.3.162:9200"]
	index => "logstash-%{+YYYY.MM.dd}"
	}


}

/usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/demo.conf


log

 /usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/file.conf

input{
        file{
        path =>["/var/log/messages", "/var/log/secure"]
        type =>"system-log"
        start_position => "beginning"
        }

}

output{
elasticsearch{
        hosts => ["10.0.3.162:9200"]
        index => "logstash-%{+YYYY.MM.dd}"
        }



}




systemctl start kibana

cp /etc/kibana/kibana.yml{,.bak}

[root@ES-1 ~]# grep -v '^#' /etc/kibana/kibana.yml
server.port: 5601
server.host: "10.0.3.161"
elasticsearch.hosts: ["http://10.0.3.162:9200"]
kibana.index: ".kibana"


http://10.0.3.161:5601/status

看看ok不？


汉化kibana
/usr/share/kibana/src/legacy/core_plugins/kibana
git clone https://github.com/anbai-inc/Kibana_Hanization.git
cp -r Kibana_Hanization/translations /usr/share/kibana/src/legacy/core_plugins/kibana
修改您的kibana配置文件kibana.yml中的配置项：i18n.locale: "zh_CN"



[root@ES-1 kibana]# find / -name "x-pack"
/usr/share/elasticsearch/bin/x-pack
/usr/share/logstash/x-pack
/usr/share/logstash/x-pack/lib/x-pack
/usr/share/kibana/node_modules/x-pack
WARNING: Could not find logstash.yml which is typically located in $LS_HOME/config or /etc/logstash. You can specify the path using --path.settings. Continuing using the defaults
/usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/file.conf



input {
        file {
        path => "/var/log/nginx/access.log"
        type => "nginx-access-log"
        start_position => "beginning"


        }
}

output {
        elasticsearch {
        hosts => ["10.0.3.162:9200"]
        index => "logstash-nginx-access-log-%{+YYYY.MM.DD}"
        }

}
~

discovery.zen.minimum_master_nodes" is too low
discovery.zen.minimum_master_nodes（默认是1）：这个参数控制的是，一个节点需要看到的具有master节点资格的最小数量，然后才能在集群中做操作。官方的推荐值是(N/2)+1，其中N是具有master资格的节点的数量（我们的情况是3，因此这个参数设置为2，但对于只有2个节点的情况，设置为2就有些问题了，一个节点DOWN掉后，你肯定连不上2台服务器了，这点需要注意）。

收集java






filebeat -logstash--redis--logstash--elasticsearch--kibana

yum localinstall -y filebeat-6.6.1-x86_64.rpm
[root@localhost filebeat]# grep -v "#" /etc/filebeat/filebeat.yml |grep -v "^$"
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/nginx/*.log
  exclude_lines: ['^DBG',"^$"]
  document_type: nginx-344
  fields:
  fields_under_root: true
filebeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: false
setup.template.settings:
  index.number_of_shards: 3
setup.kibana:
output.logstash:
  hosts: ["10.0.3.167:5044"]
processors:
  - add_host_metadata: ~
  - add_cloud_metadata: ~



filebeat -- logstash--redis


input {
  beats {
    port => 5044
    codec => json
  }
}

output {
        redis {

        host => "10.0.3.118"
        port => "6379"
        data_type => "list"
        key => "nginx-344"
        password => "baibai"
        }

}

/usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/file.conf -t

redis -- logstash--elasticsearch

input {
        redis {
                data_type => "list"
                host => "10.0.3.118"
                port => "6379"
                key => "nginx-344"
                password => "baibai"
        }
}

output {
        elasticsearch {
        hosts => ["10.0.3.162:9200"]
        index => "nginx-344-access-log-%{+YYYY.MM.dd}"
        }

}


/usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/file.conf -t










json
input {
        file {
        path => "/var/log/nginx/access.log"
        type => "nginx-access-log"
        start_position => "beginning"
        codec => "json"

        }
}

output {
        elasticsearch {
        hosts => ["10.0.3.162:9200"]
        index => "logstash-nginx-access-log-%{+YYYY.MM.dd}"
        }

}
~



#paths:
#   - /var/log/nginx/*access*.log
 #json.keys_under_root: true
 #json.overwrite_keys: true



这里面需要注意的是
json.keys_under_root： 默认这个值是FALSE的，也就是我们的json日志解析后会被放在json键上。设为TRUE，所有的keys就会被放到根节点
json.overwrite_keys: 是否要覆盖原有的key，这是关键配置，将keys_under_root设为TRUE后，再将overwrite_keys也设为TRUE，就能把filebeat默认的key值给覆盖了

还有其他的配置
json.add_error_key：添加json_error key键记录json解析失败错误
json.message_key：指定json日志解析后放到哪个key上，默认是json，你也可以指定为log等。






为了监控Redis的队列长度，可以写一个监控脚本对redis进行监控，并增加zabbix报警

[root@linux-node2 ~]# vim redis-test.py
#!/usr/bin/env python
import redis
def redis_conn():
        pool=redis.ConnectionPool(host="192.168.56.12",port=6379,db=2,password=123456)
        conn = redis.Redis(connection_pool=pool)
        data = conn.llen('filesystem-log-5612')
        print(data)
redis_conn()
[root@linux-node2 ~]# python redis-test.py     #当前redis队列长度为0
0



[2019-04-12T15:21:29,868][WARN ][logstash.outputs.elasticsearch] Could not index event to Elasticsearch. {:status=>400, :action=>["index", {:_id=>nil, :_index=>"nginx-344-access-log-2019.04.102", :_type=>"doc", :routing=>nil}, #<LogStash::Event:0x7e3d6088>], :response=>{"index"=>{"_index"=>"nginx-344-access-log-2019.04.102", "_type"=>"doc", "_id"=>"qvhsEGoBvGKOU7nDPF4F", "status"=>400, "error"=>{"type"=>"mapper_parsing_exception", "reason"=>"object mapping for [host] tried to parse field [host] as object, but found a concrete value"}}}}

不是大写的DD




[2019-04-12T16:17:39,466][WARN ][logstash.outputs.elasticsearch] Could not index event to Elasticsearch. {:status=>400, :action=>["index", {:_id=>nil, :_index=>"nginx-344-access-log-2019.04.12", :_type=>"doc", :routing=>nil}, #<LogStash::Event:0x5645a92d>], :response=>{"index"=>{"_index"=>"nginx-344-access-log-2019.04.12", "_type"=>"doc", "_id"=>"mv2fEGoBvGKOU7nDpnyE", "status"=>400, "error"=>{"type"=>"mapper_parsing_exception", "reason"=>"failed to parse field [host] of type [text]", "caused_by"=>{"type"=>"illegal_state_exception", "reason"=>"Can't get text on a START_OBJECT at 1:213"}}}}}

6版本的type
input {
        redis {
                data_type => "list"
                host => "10.0.3.118"
                port => "6379"
                key => "nginx-344"
                password => "baibai"
        }
}

output {
        elasticsearch {
        manage_template => false
        index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
        document_type => "%{[@metadata][type]}"
        hosts => ["10.0.3.162:9200"]
        #index => "nginx-344-access-log-%{+YYYY.MM.dd}"
        }

}

~
https://www.elastic.co/guide/en/logstash/7.0/plugins-inputs-beats.html


vim /etc/kibana/kibana.yml
/var/log/message
记录的太多

# Set the value of this setting to true to suppress all logging output other than error messages.
logging.quiet: true

# Set the value of this setting to true to log all events, including system usage information
# and all requests.
logging.verbose: false
