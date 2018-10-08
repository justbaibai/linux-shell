#!/bin/sh 


echo "1">/proc/sys/net/ipv4/ip_forward
sysctl -p 
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo >/dev/null 2>&1

sleep 5
yum makecache >/dev/null 2>&1
yum install -y wget >/dev/null 2>&1

wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo >/dev/null 2>&1
yum install openvpn -y >/dev/null 2>&1

if [ $? -eq 0 ];then
	echo "installed yum openvpn is ok"
else
	echo "installed is not ok"
fi

yum install -y unzip >/dev/null 2>&1
wget https://github.com/OpenVPN/easy-rsa/archive/master.zip >/dev/null 2>&1
unzip master.zip  >/dev/null 2>&1
sleep 5
mv easy-rsa-master easy-rsa
cp -R easy-rsa/ /etc/openvpn/
cd /etc/openvpn/easy-rsa/easyrsa3/
cp vars.example vars

#ea3=/etc/openvpn/easy-rsa/easyrsa3





sed -i 's@#set_var EASYRSA_REQ_COUNTRY\s"US"@set_var EASYRSA_REQ_COUNTRY    "CN"@g' /etc/openvpn/easy-rsa/easyrsa3/vars

sed -i 's@#set_var EASYRSA_REQ_PROVINCE\s"California"@set_var EASYRSA_REQ_PROVINCE   "Beijing"@g' /etc/openvpn/easy-rsa/easyrsa3/vars

sed -i 's@#set_var EASYRSA_REQ_CITY\s"San Francisco"@set_var EASYRSA_REQ_CITY       "Beijing"@g' /etc/openvpn/easy-rsa/easyrsa3/vars

sed -i 's@#set_var EASYRSA_REQ_ORG\s"Copyleft Certificate Co"@set_var EASYRSA_REQ_ORG        "my ca"@g' /etc/openvpn/easy-rsa/easyrsa3/vars

sed -i 's%#set_var EASYRSA_REQ_EMAIL\s"me@example.net"%set_var EASYRSA_REQ_EMAIL      "8888@qq.com"%g' /etc/openvpn/easy-rsa/easyrsa3/vars

sed -i 's@#set_var EASYRSA_REQ_OU\s\+"My Organizational Unit"@set_var EASYRSA_REQ_OU      "my openvpn"@g' /etc/openvpn/easy-rsa/easyrsa3/vars




#/etc/openvpn/easy-rsa/easyrsa3/easyrsa init-pki

[[ -f /usr/bin/expect ]] || { yum install expect -y >/dev/null 2>&1; }

sleep 5

sh /etc/openvpn/easy-rsa/easyrsa3/easyrsa init-pki


/usr/bin/expect << EOF
set timeout 30
spawn sh /etc/openvpn/easy-rsa/easyrsa3/easyrsa build-ca
expect {
    "Enter" { send "123456\r" ; exp_continue}
	"Re-Enter" { send "123456\r" ; exp_continue}
    "CA]:" { send "baibai\r" ; exp_continue}
    eof { exit }
}
EOF


sleep 5

/usr/bin/expect << EOF
set timeout 30
spawn sh /etc/openvpn/easy-rsa/easyrsa3/easyrsa gen-req server nopass
expect {
    "]:" { send "xiaobai\r" ; exp_continue}
    eof { exit }
}
EOF


sleep 5

/usr/bin/expect << EOF
set timeout 30
spawn sh /etc/openvpn/easy-rsa/easyrsa3/easyrsa sign server server
expect {
    "details:" { send "yes\r" ; exp_continue}
	"ca.key:" { send "123456\r" ; exp_continue}
    eof { exit }
}
EOF

sleep 5

sh  /etc/openvpn/easy-rsa/easyrsa3/easyrsa gen-dh

sleep 5


mkdir -p /root/client
cp -R /root/easy-rsa/ /root/client/

cd /root/client/easy-rsa/easyrsa3/
#sh /root/client/easy-rsa/easyrsa3/easyrsa init-pki

/usr/bin/expect << EOF
set timeout 30
spawn sh /root/client/easy-rsa/easyrsa3/easyrsa init-pki
expect {
    "removal:" { send "yes\r" ; exp_continue}
    eof { exit }
}
EOF



sleep 5
/usr/bin/expect << EOF
set timeout 30
spawn sh /root/client/easy-rsa/easyrsa3/easyrsa gen-req baibai
expect {
    "phrase:" { send "123456\r" ; exp_continue}
	"]:" { send "baibai\r" ; exp_continue}
    eof { exit }
}
EOF

cd /etc/openvpn/easy-rsa/easyrsa3/


sleep 5

sh /etc/openvpn/easy-rsa/easyrsa3/easyrsa import-req /root/client/easy-rsa/easyrsa3/pki/reqs/baibai.req baibai






sleep 5

/usr/bin/expect << EOF
set timeout 30
spawn sh /etc/openvpn/easy-rsa/easyrsa3/easyrsa sign client baibai 
expect {
    "details:" { send "yes\r" ; exp_continue}
	"key:" { send "123456\r" ; exp_continue}
    eof { exit }
}
EOF


sleep 5






 
cp /etc/openvpn/easy-rsa/easyrsa3/pki/ca.crt /etc/openvpn
cp /etc/openvpn/easy-rsa/easyrsa3/pki/private/server.key /etc/openvpn
cp /etc/openvpn/easy-rsa/easyrsa3/pki/issued/server.crt /etc/openvpn
cp /etc/openvpn/easy-rsa/easyrsa3/pki/dh.pem /etc/openvpn
cp /etc/openvpn/easy-rsa/easyrsa3/pki/ca.crt /root/client
cp /etc/openvpn/easy-rsa/easyrsa3/pki/issued/baibai.crt  /root/client
cp /root/client/easy-rsa/easyrsa3/pki/private/baibai.key /root/client
 
cp /usr/share/doc/openvpn-2.4.6/sample/sample-config-files/server.conf /etc/openvpn/

cp /etc/openvpn/server.conf{,.bak}

#>/etc/openvpn/server.conf 

echo '
local 10.0.3.88
port 1194
proto udp
dev tun
ca /etc/openvpn/ca.crt
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key 
dh /etc/openvpn/dh.pem
server 10.0.128.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 114.114.114.114"
keepalive 10 120
comp-lzo
max-clients 100
persist-key
persist-tun
status openvpn-status.log
verb 3'>/etc/openvpn/server.conf 


echo '
client
dev tun
proto udp
remote 10.0.3.88 1194
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
cert baibai.crt
key baibai.key
comp-lzo
verb 3
' >/root/client/client.ovpn


yum install -y lrzsz >/dev/null 2>&1


cd /root/client &&
sz -y baibai.crt  baibai.key  ca.crt  client.ovpn


sleep 5
openvpn /etc/openvpn/server.conf &

























