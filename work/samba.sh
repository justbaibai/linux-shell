#!/bin/sh
yum -y install samba samba-client samba-common
mkdir write-read only-read
cd /etc/samba/
 cp -a smb.conf smb.conf.bak
 chmod 777 -R write-read/
 chmod 755  -R only-read/
 chown -R nobody.nobody smb

vim /etc/samba/smb.conf
 netbios name=SHAREDOCS
 server string=Samba Server
 security = user
 map to guest = Bad User
 [SHAREDOCS]
 path=/smb/docs/
 writable=yes
 browseable=yes
 public= yes
 guest ok=yes
 readable = yes
 available = yes
 create mode= 0664
 directory mode= 0775




systemctl enable smb
systemctl restart smb
 systemctl statue firewalld
