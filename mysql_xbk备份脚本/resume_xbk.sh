#!/bin/sh
innobackupex --defaults-file=/etc/my.cnf --user=backup --password=123456 --databases=zabbix /data/backup/
 innobackupex --apply-log /data/backup/2018-05-21_15-02-53/
  innobackupex --copy-back /data/backup/2018-05-21_15-02-53/
   chown -R mysql.mysql /var/lib/mysql/*

    innobackupex --apply-log --redo-only /data/backup/2018-05-21_15-02-53/
    innobackupex --apply-log --redo-only  --user-memory=1G /data/backup/2018-05-21_15-02-53/ --incremental-dir=/data/backup/increment_data/2018-05-21_15-21-11/
innobackupex --apply-log /data/backup/2018-05-21_15-02-53/ --incremental-dir=/data/backup/increment_data/2018-05-21_15-30-13/
增量备份的恢复应按照备份的顺利逐个逐个replay，需要使用--apply-log --redo-only选项。
仅仅最后一个增量备份不需要使用–redo-only选项。
如果仅有一个增量  全备用 --apply-log --redo-only选项 增量用 --apply-log

innobackupex --apply-log --redo-only BASE-DIR
innobackupex --apply-log --redo-only BASE-DIR --incremental-dir=INCREMENTAL-DIR-1
innobackupex --apply-log BASE-DIR --incremental-dir=INCREMENTAL-DIR-2
innobackupex  --copy-back /backup/mysql/full/
chown -R mysql.mysql /var/lib/mysql/

     tar xf  incr0_2020-01-14-15-57-56.tar.gz
     ls
     tar xf full_2020-01-14-15-54-16.tar.gz
    ls
    innobackupex --apply-log --redo-only full/
    innobackupex --apply-log  full/ --incremental-dir=incr0
    innobackupex --copy-back full/
  cd /usr/local/mysql-5.7.25/
  cd /usr/local/mysql/data/
  ll
  chown -R mysql.mysql /usr/local/mysql-5.7.25/*
  ll
 /etc/init.d/mysqld start
  mysql -uroot -p
  cd
  cd bakmysql/
  ls
  ll
 /usr/local/mysql/bin/mysqlbinlog --no-defaults --start-position='726' --stop-position='2821'  mysql-bin.000*|mysql -uroot -p
 追加二进制日志
 xtrabackup_binlog_info
 /usr/local/mysql/bin/mysqlbinlog  --no-defaults -v  --base64-output=DECODE-ROWS mysql-bin.000007

 mysql> create user 'bkpuser'@'localhost' identified by '123456';

mysql> grant reload,lock tables,process,replication client on *.* to 'bkpuser'@'localhost'
