#!/bin/sh
yum install -y  rpcbind nfs-utils
systemctl start rpcbind
mkdir /baibai
mount -t nfs 10.0.3.26:/data  /baibai
