#!/bin/sh

#openLDAP 常用名词解释

#o– organization（组织-公司）
#ou – organization unit（组织单元/部门）
#c - countryName（国家）
#dc - domainComponent（域名组件）
#cn - common name（常用名称）
#dn - distinguished name（专有名称）
#OpenLDAP2.4.44安装和配置
yum install -y openldap openldap-*  migrationtools
slappasswd -s 123456
vi /etc/openldap/slapd.d/cn\=config/olcDatabase\=\{2\}hdb.ldif
修改内容：
olcSuffix: dc=baibai,dc=com
olcRootDN: cn=root,dc=baibai,dc=com
添加内容：
olcRootPW: {SSHA}r2fcL6Exxgr8oKkaWROUQDCZKqXrH7bE
4、修改验证
vi /etc/openldap/slapd.d/cn\=config/olcDatabase\=\{1\}monitor.ldif

olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=extern
 al,cn=auth" read by dn.base="cn=root,dc=baibai,dc=com" read by * none
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
cp /usr/share/openldap-servers/slapd.ldif  /etc/openldap/slapd.conf
cp /etc/rsyslog.conf{,.bak}

echo "local4.*                             /var/log/ldap.log" >>/etc/rsyslog.conf
systemctl restart rsyslog

chown ldap:ldap -R /var/lib/ldap
chmod 700 -R /var/lib/ldap

6、验证
slaptest -u
看见：config file testing succeeded  #验证成功，否则失败。

7、授权，若不授权启动时或报错，权限不足
chown ldap:ldap -R /var/run/openldap
chown -R ldap:ldap /etc/openldap/

8、启动
systemctl start slapd
systemctl enable slapd

9、执行ldapsearch -x检查是否有如下输出
ldapsearch -x -b '' -s base'(objectclass=*)'

# extended LDIF
#
# LDAPv3
# base <> with scope baseObject
# filter: (objectclass=*)
# requesting: ALL
#

#
dn:
objectClass: top
objectClass: OpenLDAProotDSE

# search result
search: 2
result: 0 Success






下面不是此本版本的安装方法


yum install -y openldap openldap-*  migrationtools
cp /usr/share/openldap-servers/slapd.ldif  /etc/openldap/slapd.conf
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
chown -R ldap.ldap /etc/openldap
chown -R ldap.ldap /var/lib/ldap
yum install krb5* -y
 cp /usr/share/doc/krb5-server-ldap-1.15.1/kerberos.schema /etc/openldap/schema/

 120   chown -R ldap.ldap /var/lib/ldap

 121  rm -rf /etc/openldap/slapd.d/*

 122  slaptest -f /etc/openldap/slapd.conf -F /etc/openldap/slapd.d
 123  systemctl start slapd
 124  chown -R ldap:ldap /etc/openldap/slapd.d
 125  systemctl start slapd


cp /etc/rsyslog.conf{,.bak}

echo "local4.*                             /var/log/ldap.log" >>/etc/rsyslog.conf
systemctl restart rsyslog
slappasswd -s 123456
/etc/openldap/slapd.conf




systemctl start slapd
slaptest -f /etc/openldap/slapd.conf
rm -rf /etc/openldap/slapd.d/*
slaptest -f /etc/openldap/slapd.conf -F /etc/openldap/slapd.d
chown -R ldap:ldap /etc/openldap/slapd.d
systemctl restart slapd

pw=`slappasswd -s 123456`
echo "
include         /etc/openldap/schema/core.schema
include         /etc/openldap/schema/cosine.schema
include         /etc/openldap/schema/duaconf.schema
include         /etc/openldap/schema/dyngroup.schema
include         /etc/openldap/schema/inetorgperson.schema
include         /etc/openldap/schema/java.schema
include         /etc/openldap/schema/misc.schema
include         /etc/openldap/schema/nis.schema
include         /etc/openldap/schema/openldap.schema
include         /etc/openldap/schema/ppolicy.schema
include         /etc/openldap/schema/collective.schema
include         /etc/openldap/schema/kerberos.schema
allow bind_v2
argsfile /var/run/openldap/slapd.args
pidfile /var/run/openldap/slapd.pid
loglevel        4095
TLSCACertificatePath /etc/openldap/certs
TLSCertificateFile "\"OpenLDAP Server\""
TLSCertificateKeyFile /etc/openldap/certs/password
access to *
    by self write
    by users read
    by anonymous read
database config
access to *
        by dn.exact="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage
        by * none
database monitor
access to *
        by dn.exact="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" read
        by dn.exact="cn=admin,ou=ldap,ou=admin,dc=baibai,dc=com" read
        by * none
database        bdb
suffix          "dc=baibai,dc=com"
checkpoint      1024 15
cachesize       10000
rootdn          "cn=admin,ou=ldap,ou=admin,dc=baibai,dc=com"
rootpw          $pw
directory       /var/lib/ldap
index objectClass                       eq,pres
index ou,cn,mail,surname,givenname      eq,pres,sub
index uidNumber,gidNumber,loginShell    eq,pres
index uid,memberUid                     eq,pres,sub
index nisMapName,nisMapEntry            eq,pres,sub">/etc/openldap/slapd.conf


rm -rf /etc/openldap/slapd.d/*
systemctl start slapd
slaptest -f /etc/openldap/slapd.conf -F /etc/openldap/slapd.d
chown -R ldap:ldap /etc/openldap/slapd.d
systemctl stop slapd

slaptest -f /etc/openldap/slapd.conf


bdb_db_open: database "dc=baibai,dc=com": alock package is unstable.
rm -f /var/lib/ldap/alock



config error processing cn=config: <olcTLSCertificateFile> extra cruft after <(null)>






就是说，下面的命令中，要完整的复制sldap.conf中的“rootdn "cn=admin,ou=ldap,ou=admin,dc=testserver,dc=com"”条目信息，不能多，不能少。
ldapsearch -x -D "cn=admin,ou=ldap,ou=admin,dc=baibai,dc=com" -h 10.0.3.167 -W -b 'ou=People,dc=baibai,dc=com'
11. LDAP创建成功之后，需要创建数据。由于我是迁移数据过来，只是将生产的ldap数据导出导入。

ldap数据备份的方式有两种：一种是通过ldapsearch ，一种是通过slapcat命令。很多人都是建议通过slapcat来完成，但是我测试一下，没有成功，就先使用ldapsearch导出，ldapadd导入的

/usr/sbin/slapcat > /tmp/liang/ldapdbak.ldif
/usr/sbin/slapadd -l  /tmp/liang/ldapdbak.ldif

LDAP Account Manager (LAM) 新的
wget https://github.com/LDAPAccountManager/lam/releases/download/lam_6_6/ldap-account-manager-6.6-0.fedora.1.noarch.rpm
 wget http://prdownloads.sourceforge.net/lam/ldap-account-manager-6.7.tar.bz2
yum -y install bzip2
tar -jxf ldap-account-manager-6.7.tar.bz2

mv config.cfg.sample  config.cfg
mv samba3.conf.sample  lam.conf
chown -R nginx.nginx /data
