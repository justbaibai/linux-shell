#!/bin/sh
yum install etcd -y >/dev/null 2>&1
if [ $? -eq 0 ]; then
	echo "etcd install is ok"
else
	echo "etcd install is not ok"
fi
sleep 5s
cp /etc/etcd/etcd.conf{,.bak}

echo '
#[Member]
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="http://10.0.3.111:2380"
ETCD_LISTEN_CLIENT_URLS="http://10.0.3.111:2379"
ETCD_NAME="baibaic"
#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://10.0.3.111:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://10.0.3.111:2379"
ETCD_INITIAL_CLUSTER="baibaic=http://10.0.3.111:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster-01"
ETCD_INITIAL_CLUSTER_STATE="new"
'>/etc/etcd/etcd.conf

systemctl enable etcd >/dev/null 2>&1
systemctl start etcd >/dev/null 2>&1

systemctl status etcd

netstat -lntup|grep etcd
sleep 2s
echo "etcd is ok"



#name      节点名称
#data-dir      指定节点的数据存储目录
#listen-peer-urls      监听URL，用于与其他节点通讯
#listen-client-urls    对外提供服务的地址：比如 http://ip:2379,http://127.0.0.1:2379 ，客户端会连接到这里和 etcd 交互
#initial-advertise-peer-urls   该节点同伴监听地址，这个值会告诉集群中其他节点
#initial-cluster   集群中所有节点的信息，格式为 node1=http://ip1:2380,node2=http://ip2:2380,… 。注意：这里的 node1 是节点的 --name 指定的名字；后面的 ip1:2380 是 --initial-advertise-peer-urls 指定的值
#initial-cluster-state     新建集群的时候，这个值为 new ；假如已经存在的集群，这个值为 existing
#initial-cluster-token     创建集群的 token，这个值每个集群保持唯一。这样的话，如果你要重新创建集群，即使配置和之前一样，也会再次生成新的集群和节点 uuid；否则会导致多个集群之间的冲突，造成未知的错误
#advertise-client-urls     对外公告的该节点客户端监听地址，这个值会告诉集群中其他节点
