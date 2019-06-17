#!/bin/sh
#wget https://www.percona.com/downloads/percona-toolkit/3.0.13/binary/redhat/7/x86_64/percona-toolkit-3.0.13-1.el7.x86_64.rpm
#yum localinstall -y  percona-toolkit-3.0.13-1.el7.x86_64.rpm
由于新的MySQL重做日志和数据字典格式，8.0版本只支持mysql8.0和percona8.0
早于mysql8.0的版本需要使用xtrabackup2.4备份和恢复.
wget https://www.percona.com/downloads/Percona-XtraBackup-2.4/Percona-XtraBackup-2.4.13/binary/redhat/7/x86_64/percona-xtrabackup-24-2.4.13-1.el7.x86_64.rpm
 yum localinstall -y percona-xtrabackup-24-2.4.13-1.el7.x86_64.rpm

mysql> create user 'bkpuser'@'localhost' identified by '123456';

mysql> grant reload,lock tables,process,replication client on *.* to 'bkpuser'@'localhost';

mysql> flush privileges;
mkdir -p /var/lib/mysql
ln -s /tmp/mysql.sock /var/lib/mysql/mysql.sock
 /usr/local/mysql/bin/mysqlbinlog -v --base64-output=DECODE-ROWS mysql-bin.000864|grep -C 10 -i drop

 产生这个问题的原因是因为我在my.cnf中的client选项组中添加了
 default-character-set=utf8

 要解决这个bug的方法还是有的，
 一种方法是使用：--no-defaults

mysqlbinlog  --no-defaults -v --base64-output=DECODE-ROWS mysql-bin.000001
--start-datetime：从二进制日志中读取指定等于时间戳或者晚于本地服务器的时间
--stop-datetime：从二进制日志中读取指定小于时间戳或者等于本地服务器的时间 取值和上述一样
--start-position：从二进制日志中读取指定position 事件位置作为开始。
--stop-position：从二进制日志中读取指定position 事件位置作为事件截至
mysqlbinlog --no-defaults --start-position='1085' --stop-position='1235'  mysql-bin.000*|mysql -uroot -p




innobackupex --defaults-file=/etc/my.cnf  --user=$user --password=$pwd  --no-timestamp  --incremental  /backup/xtra_inc_$dt --incremental-basedir=/backup/xtra_base_$lastday > /tmp/$log 2>&1
innobackupex --defaults-file=/etc/my.cnf  --user=bkpuser --password=123456 /bak

innobackupex --apply-log /root/xtrabackup/
innobackupex --copy-back /root/xtrabackup

 innobackupex --copy-back /bak/2019-04-03_03-10-03/
 chown -R mysql.mysql /usr/local/mysql/*
/usr/local/mysql/bin/mysqlbinlog  --start-position='1002'  mysql-bin.000*
yum update trousers
