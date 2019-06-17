#!/bin/sh
基于msql gtid 主从复制
先在主库上全备
参考innobackupex


主库配置：

gtid_mode=on
enforce_gtid_consistency=on
#log_slave_updates=1
主库
server_id： 设置MySQL实例的server_id，每个server_id不能一样
gtid_mode=ON： MySQL实例开启GTID模式
enforce_gtid_consitency=ON：使用GTID模式复制时，需要开启参数，用来保证数据的一致性。
log-bin: MySQL必须要开启binlog
#binlog_format=mixed: binlog格式为row
#skip-slave-start=1(可选): 当SLAVE数据库启动的时候，SLAVE不会启动复制
log-slave-updates=true  //在从服务器进入主服务器传入过来的修改日志所使用，在Mysql5.7之前主从架构上使用gtid模式的话，必须使用此选项，在Mysql5.7取消了，会增加系统负载。
master_info_repository=TABLE
relay_log_info_repository=TABLE　//指定中继日志的存储方式，默认是文件，这样配置是使用了 两个表，是INNODB存储引擎，好处是当出现数据库崩溃时，利用INNODE事务引擎的特点，对这两个表进行恢复，以保证从服务器可以从正确位置恢复数据。
#sync-master-info=1    　　　　   //同步master_info,任何事物提交以后都必须要把事务提交以后的二进制日志事件的位置对应的文件名称，记录到master_info中，下次启动自动读取，保证数据无丢失
slave-parallel-workers=2  　　　　 //设定从服务器的启动线程数，0表示不启动
grant replication client,replication slave on *.* to baibai@'10.0.3.%' identified by 'baibai';  //ip段与账号密码
flush privileges;  //刷新权限

从库

gtid_mode=on
enforce_gtid_consistency=on
log_slave_updates=1 决定SLAVE从Master接收到更新且执行是否记录到SLAVE的binlog中
binlog_format=mixed
master_info_repository=TABLE
relay_log_info_repository=TABLE  //指定中继日志的存储方式，默认是文件，这样配置是使用了 两个表，是INNODB存储引擎，好处是当出现数据库崩溃时，利用INNODE事务引擎的特点，对这两个表进行恢复，以保证从服务器可以从正确位置恢复数据。
slave-parallel-workers=2  //开启线程数，0就表示禁用线程

change master to master_host='10.0.3.118',master_user='baibai',master_password='baibai',master_auto_position=1;
start slave;
show slave status\G
io sql 是不是两个ok


主从 binlog_format 设置关系
1. 主库是row，从库必须是row/mixed。如果是statement，主库有变更时，从库报如下错误（无论什么变更都报错，如insert/update/delete/alter等）：
    Last_Error: Error executing row event: 'Cannot execute statement: impossible to write to binary log since statement is in row format and BINLOG_FORMAT = STATEMENT.'

2. 主库是statement，从库可以是任意模式（statement/mixed/row），但可能造成数据不一致，故不建议使用。

3. 主库是mixed，从库必须是row/mixed格式。如果从库是statement，主库一般情况下修改数据，从库不报错。特殊情况下，则从库报如下错误。
    Last_Error: Error executing row event: 'Cannot execute statement: impossible to write to binary log since statement is in row format and BINLOG_FORMAT = STATEMENT.'

以上所说的一般情况是：主库将binlog记录为statement格式。
以上所说的特殊情况是：主库将binlog记录为row格式。具体为以下几种：
(1) 当时用UUID()函数时
(2) 当一个或多个拥有AUTO_INCREMENT列的表被更新同时有‘trigger’或者‘stored function’被调用时
(3) 执行INSERT DELAYED时
(4) 当视图里的某一部分需要row-based复制（例如UUID()）时，创建该视图的语句被改为row-based
(5) 使用用户自定义函数（UDF）时
(6) 当某语句被判定为row-based，并且执行它的session需要用到临时表，则session下的所有子语句都将以ROW格式记录
(7) 当使用USER(),CURRENT_USER()或者 CURRENT_USER
(8) 当语句引用了一个或多个system variables。
(9) 当使用LOAD_FILE()
