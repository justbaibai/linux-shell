#!/bin/bash
get_backup_conf(){
# 获得程序路径名
program_dir=$(dirname $(cd $(dirname $0); pwd))
# 读取配置文件中的所有变量值, 设置为全局变量
#或者source进来也行 在或者直接写变量
TODAY=`date +%Y-%m-%d-%H-%M-%S`
BEGINTIME=`date +"%Y-%m-%d %H:%M:%S"`
#mysqladmin的路径
# 配置文件
conf_file="$program_dir/conf/backup.conf"
# mysql 用户
user_name=`sed '/^user=/!d;s/.*=//' $conf_file`
# mysql 密码
password=`sed '/^password=/!d;s/.*=//' $conf_file`
# mysql 备份目录
backup_dir=`sed '/^backup_dir=/!d;s/.*=//' $conf_file`
# mysql 备份压缩打包目录
gzip_dir=`sed '/^gzip_dir=/!d;s/.*=//' $conf_file`
# percona-xtrabackup命令xtrabackup路径
innobackupex_bin=`sed '/^innobackupex_bin=/!d;s/.*=//' $conf_file`
# 备份错误日志文件
error_log=`sed '/^error_log=/!d;s/.*=//' $conf_file`
# MySQL配置文件路径
mycnf=`sed '/^mycnf=/!d;s/.*=//' $conf_file`
backup_log=`sed '/^backup_log=/!d;s/.*=//' $conf_file`
#mysqladmin的路径
MYSQLADMIN=`sed '/^MYSQLADMIN=/!d;s/.*=//' $conf_file`
USEROPTIONS="--user=$user_name --password=$password"
#临时文件路径
#tempfile=`sed '/^tempfile/!d;s/.*=//' $conf_file`
#mysql socket 文件路径
socket=`sed '/^socket/!d;s/.*=//' $conf_file`
backup_gz_keep_day=`sed '/^backup_gz_keep_day/!d;s/.*=//' $conf_file`
log_dir=`sed '/^log_dir/!d;s/.*=//' $conf_file`
temp_dir=`sed '/^temp_dir/!d;s/.*=//' $conf_file`
TMPFILE=$program_dir/$temp_dir/$TODAY-tempfile.txt
#db_ip="10.0.3.200"
#db_user=baibai
#db_pwd=123456
#db_port=3306
#db_name=beifen
}
mk_dir(){
# 创建相关目录
if [ -f $program_dir/$temp_dir/lock.txt ];then
  echo 1 >$program_dir/$temp_dir/test.txt
else
  mkdir -p $program_dir/$backup_dir
  mkdir -p $program_dir/$log_dir
  mkdir -p $program_dir/$temp_dir
  mkdir -p $program_dir/$gzip_dir
  touch $program_dir/$temp_dir/lock.txt
  touch $program_dir/$temp_dir/tempfile.txt

fi
}
#检查配置和msql和xbk的检查函数
function test_conf_file() {
  # 判断每个变量是否在配置文件中有配置，没有则退出程序
  if [ ! -n "$user_name" ]; then echo 'fail: configure file user not set' >> $program_dir/$log_dir/$error_log; exit 2; fi
  if [ ! -n "$password" ]; then echo 'fail: configure file password not set' >> $program_dir/$log_dir/$error_log; exit 2; fi
  if [ ! -n "$backup_dir" ]; then echo 'fail: configure file backup_dir not set' >> $program_dir/$log_dir/$error_log; exit 2; fi
  if [ ! -n "$gzip_dir" ]; then echo 'fail: configure file backup_dir not set'; exit 2; fi
  if [ ! -n "$backup_gz_keep_day" ]; then echo 'fail: configure file backup_gz_keep_day not set' >> $program_dir/$log_dir/$error_log; exit 2; fi
  if [ ! -n "$backup_log" ]; then echo 'fail: configure file backup_log not set' >> $program_dir/$log_dir/$error_log; exit 2; fi
  if [ ! -n "$mycnf" ]; then echo 'fail: configure file mycnf not set'; >> $program_dir/$log_dir/$error_log; exit 2; fi
  if [ ! -n "$temp_dir" ]; then echo 'fail: configure file temp_dir not set'; >> $program_dir/$log_dir/$error_log; exit 2; fi
  if [ ! -n "$socket" ]; then echo 'fail: configure file socket not set'; >> $program_dir/$log_dir/$error_log; exit 2; fi
  if [ ! -n "$error_log" ]; then echo 'fail: configure file error_log not set'; >> $program_dir/$log_dir/$error_log; exit 2; fi
  if [ ! -n "$log_dir" ]; then echo 'fail: configure file log_dir not set'; >> $program_dir/$log_dir/$error_log; exit 2; fi
  if [ ! -n "$innobackupex_bin" ]; then echo 'fail: configure file innobackupex_bin not set' >> $program_dir/$log_dir/$error_log; exit 2; fi
  if [ ! -n "$MYSQLADMIN" ]; then echo 'fail: configure file MYSQLADMIN not set' >> $program_dir/$log_dir/$error_log; exit 2; fi
  if [ ! -f "$MYSQLADMIN" ] ; then
   echo "HALTED: MYSQLADMIN is not bin." >>$program_dir/$log_dir/$error_log; exit 2
  fi

  if [ ! -f "$innobackupex_bin" ] ; then
   echo "HALTED: innobackupex is not install." >>$program_dir/$log_dir/$error_log; exit 2
  fi

  if [ -z "`$MYSQLADMIN $USEROPTIONS status | grep 'Uptime'`" ] ; then
   echo "HALTED: MySQL does not appear to be running." >>$program_dir/$log_dir/$error_log; exit 2
  fi
}


#备份成功或失败的日志
log_err(){
  if [ -z "`tail -1 $TMPFILE | grep 'completed OK!'`" ] ; then
   echo "innobackupex failed:" >> $program_dir/$log_dir/$error_log;
   echo "---------- ERROR OUTPUT from $TODAY ----------" >> $program_dir/$log_dir/$error_log;
   echo "please read /temp/tempfile.txt " >> $program_dir/$log_dir/$error_log;
   dbnum=`cat $program_dir/$temp_dir/tempfile.txt`
  # /usr/local/mysql/bin/mysql  -h${db_ip} -u${db_user} -p${db_pwd} -P${db_port} -D${db_name} -s -e "insert into xbk(name,dbstatus,dbdate) values(\"${dbnum}\",'success',\"${TODAY}\")"
   exit 1
  fi

}
#用时时间
time_use(){

ENDTIME=`date +"%Y-%m-%d %H:%M:%S"`
begin_data=`date -d "$BEGINTIME" +%s`
end_data=`date -d "$ENDTIME" +%s`
spendtime=`expr $end_data - $begin_data`
echo "it takes $spendtime sec for packing the data directory" >>$program_dir/$log_dir/xtrabackup_time.txt
}
#备份
function backup(){
if [ ! -d "$program_dir/$backup_dir/full" ];then
  echo "#####start full backup at $BEGINTIME to directory full" >> $program_dir/$log_dir/xtrabackup_time.txt
  $innobackupex_bin --defaults-file=$mycnf --no-timestamp --user=$user_name --password=$password --socket=$socket  $program_dir/$backup_dir/full >> $TMPFILE 2>&1
  #/usr/local/mysql/bin/mysql  -h${db_ip} -u${db_user} -p${db_pwd} -P${db_port} -D${db_name} -s -e "insert into xbk(name,dbstatus,dbdate) values('full','success',\"${TODAY}\")"
  echo "full_$TODAY" >> $program_dir/$temp_dir/baibai.txt
  echo "full" > $program_dir/$temp_dir/tempfile.txt
  break;
elif [ ! -d "$program_dir/$backup_dir/incr0" ];then
  echo "#####start 0 incremental backup at $BEGINTIME to directory incr0" >>$program_dir/$log_dir/xtrabackup_time.txt
  $innobackupex_bin --defaults-file=$mycnf  --no-timestamp --user=$user_name --password=$password --socket=$socket --incremental --incremental-basedir=$program_dir/$backup_dir/full $program_dir/$backup_dir/incr0 >> $TMPFILE 2>&1
  #/usr/local/mysql/bin/mysql  -h${db_ip} -u${db_user} -p${db_pwd} -P${db_port} -D${db_name} -s -e "insert into xbk(name,dbstatus,dbdate) values('incr0','success',\"${TODAY}\")"
  echo "incr0_$TODAY" >> $program_dir/$temp_dir/baibai.txt
  echo "incr0" > $program_dir/$temp_dir/tempfile.txt
  break;
elif [ ! -d "$program_dir/$backup_dir/incr1" ];then
echo "#####start 1 incremental backup at $BEGINTIME to directory incr1" >>$program_dir/$log_dir/xtrabackup_time.txt
$innobackupex_bin --defaults-file=$mycnf  --no-timestamp --user=$user_name --password=$password --socket=$socket  --incremental --incremental-basedir=$program_dir/$backup_dir/incr0 $program_dir/$backup_dir/incr1 >> $TMPFILE 2>&1
#/usr/local/mysql/bin/mysql  -h${db_ip} -u${db_user} -p${db_pwd} -P${db_port} -D${db_name} -s -e "insert into xbk(name,dbstatus,dbdate) values('incr1','success',\"${TODAY}\")"
echo "incr1_$TODAY" >> $program_dir/$temp_dir/baibai.txt
echo "incr1" > $program_dir/$temp_dir/tempfile.txt
break;
elif [ ! -d "$program_dir/$backup_dir/incr2" ];then
echo "#####start 2 incremental backup at $BEGINTIME to directory incr2" >>$program_dir/$log_dir/xtrabackup_time.txt
$innobackupex_bin --defaults-file=$mycnf  --no-timestamp --user=$user_name --password=$password --socket=$socket  --incremental --incremental-basedir=$program_dir/$backup_dir/incr1 $program_dir/$backup_dir/incr2 >> $TMPFILE 2>&1
#/usr/local/mysql/bin/mysql  -h${db_ip} -u${db_user} -p${db_pwd} -P${db_port} -D${db_name} -s -e "insert into xbk(name,dbstatus,dbdate) values('incr2','success',\"${TODAY}\")"
echo "incr2_$TODAY" >> $program_dir/$temp_dir/baibai.txt
echo "incr2" > $program_dir/$temp_dir/tempfile.txt
break;
elif [ ! -d "$program_dir/$backup_dir/incr3" ];then
echo "#####start 3 incremental backup at $BEGINTIME to directory incr3" >>$program_dir/$log_dir/xtrabackup_time.txt
$innobackupex_bin --defaults-file=$mycnf  --no-timestamp --user=$user_name --password=$password --socket=$socket  --incremental --incremental-basedir=$program_dir/$backup_dir/incr2 $program_dir/$backup_dir/incr3 >> $TMPFILE 2>&1
#/usr/local/mysql/bin/mysql  -h${db_ip} -u${db_user} -p${db_pwd} -P${db_port} -D${db_name} -s -e "insert into xbk(name,dbstatus,dbdate) values('incr3','success',\"${TODAY}\")"
echo "incr3_$TODAY" >> $program_dir/$temp_dir/baibai.txt
echo "incr3" > $program_dir/$temp_dir/tempfile.txt
break;
elif [ ! -d "$program_dir/$backup_dir/incr4" ];then
echo "#####start 4 incremental backup at $BEGINTIME to directory incr4" >>$program_dir/$log_dir/xtrabackup_time.txt
$innobackupex_bin --defaults-file=$mycnf  --no-timestamp --user=$user_name --password=$password --socket=$socket  --incremental --incremental-basedir=$program_dir/$backup_dir/incr3 $program_dir/$backup_dir/incr4 >> $TMPFILE 2>&1
#/usr/local/mysql/bin/mysql  -h${db_ip} -u${db_user} -p${db_pwd} -P${db_port} -D${db_name} -s -e "insert into xbk(name,dbstatus,dbdate) values('incr4','success',\"${TODAY}\")"
echo "incr4_$TODAY" >> $program_dir/$temp_dir/baibai.txt
echo "incr4" > $program_dir/$temp_dir/tempfile.txt
break;
elif [ ! -d "$program_dir/$backup_dir/incr5" ];then
echo "#####start 5 incremental backup at $BEGINTIME to directory incr5" >>$program_dir/$log_dir/xtrabackup_time.txt
$innobackupex_bin --defaults-file=$mycnf  --no-timestamp --user=$user_name --password=$password --socket=$socket  --incremental --incremental-basedir=$program_dir/$backup_dir/incr4 $program_dir/$backup_dir/incr5 >> $TMPFILE 2>&1
#/usr/local/mysql/bin/mysql  -h${db_ip} -u${db_user} -p${db_pwd} -P${db_port} -D${db_name} -s -e "insert into xbk(name,dbstatus,dbdate) values('incr5','success',\"${TODAY}\")"
echo "incr5_$TODAY" >> $program_dir/$temp_dir/baibai.txt
echo "incr5" > $program_dir/$temp_dir/tempfile.txt
break;
fi
}
# 删除之前的压缩备份(一般在全备完成后使用)
function delete_before_gzbackup() {
  find $program_dir/$gzip_dir/ -mtime +$backup_gz_keep_day -name "*.tar.gz"  -exec rm -rf {} \;
#-mmin 分钟  mtime 天
}




# 删除旧的文件备份
function del_old_backup() {

num_h=`wc -l $program_dir/$temp_dir/baibai.txt|awk '{print $1}'`

if [ $num_h -eq 7 ];then
  cd $program_dir/$backup_dir/&&rm -fr *
  >$program_dir/$temp_dir/baibai.txt
  echo "$TODAY :delete old backup is ok" >> $program_dir/$temp_dir/last_del_old.log
else
  echo "$TODAY : please ignore this info" >> $program_dir/$temp_dir/last_del_old.log
fi
}

# 打包备份
function tar_backup_file() {
num=`cat $program_dir/$temp_dir/tempfile.txt`
case "$num" in
        full)
          cd $program_dir/$backup_dir&&tar -czf $program_dir/$gzip_dir/full_$TODAY.tar.gz $num
                ;;
        incr0)
          cd $program_dir/$backup_dir&&tar  -czf $program_dir/$gzip_dir/incr0_$TODAY.tar.gz $num
                ;;
        incr1)
          cd $program_dir/$backup_dir&&tar  -czf $program_dir/$gzip_dir/incr1_$TODAY.tar.gz $num
                ;;
        incr2)
          cd $program_dir/$backup_dir&&tar  -czf $program_dir/$gzip_dir/incr2_$TODAY.tar.gz $num
                ;;
        incr3)
          cd $program_dir/$backup_dir&&tar  -czf $program_dir/$gzip_dir/incr3_$TODAY.tar.gz $num
                ;;
        incr4)
          cd $program_dir/$backup_dir&&tar  -czf $program_dir/$gzip_dir/incr4_$TODAY.tar.gz $num
               ;;
        incr5)
          cd $program_dir/$backup_dir&&tar  -czf $program_dir/$gzip_dir/incr5_$TODAY.tar.gz $num
               ;;
        *)
           echo "err beifen gz">>$program_dir/$log_dir/$error_log
esac

}
# 发送备份到远程
function send_backup_to_remote() {
  echo "send $1 remote ok"
}

# 执行主函数
function main() {
  get_backup_conf
  mk_dir
  test_conf_file
  backup
  log_err
  time_use
  tar_backup_file
  del_old_backup
  delete_before_gzbackup
}
main
#0 0 * * * sh /root/test/bin/backup_xb.sh >/dev/null 2>&1
