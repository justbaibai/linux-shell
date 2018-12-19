#!/bin/sh
yum install -y nfs-utils rpcbind
mkdir /data
chown -R nfsnobody.nfsnobody /data
echo "
/data  10.0.3.0/24(rw,sync,all_squash,anonuid=65534,anongid=65534)
">/etc/exports
cat >> /etc/sysctl.conf << EOF
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
EOF
sysctl -p
service rpcbind start
service nfs start
