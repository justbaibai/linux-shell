#!/bin/sh
wget -P /usr/local/src  https://github.com/justbaibai/linux-shell/blob/master/Rsync-Sersync/sersync2.5.4_64bit_binary_stable_final.tar.gz
mv /usr/local/src/GNU-Linux-x86/ /usr/local/sersync
 cp confxml.xml{,.bak}
 mv sersync2 sersync


 nohup /usr/local/sersync/sersync -r -d -o /usr/local/sersync/confxml.xml >/usr/local/sersync/rsync.log 2>&1 &
 <localpath watch="/xiaobai">#源服务器同步目录
<remote ip="10.0.3.26" name="backup"/>目标服务器IP地址  目标服务器rsync同步目录模块名称
<commonParams params="-avz"/>  同步参数
<auth start="true" users="baibai" passwordfile="/etc/rsync.password"/>目标服务器rsync同步用户名  目标服务器rsync同步用户的密码在源服务器的存放路径
<failLog path="/usr/local/sersync/rsync_fail_log.sh" timeToExecute="60"/>  脚本运行失败日志记录
<crontab start="true" schedule="600"><!--600mins--> #设置为true，每隔600分钟执行一次全盘同步
sed -i 's#<localpathwatch="/opt/tongbu">#<localpathwatch="/backup">#g' $sedir/confxml.xml

sed -i 's#<remote ip="127.0.0.1"name="tongbu1"/>#<remote ip="rsync"name="backup"/>#g' $sedir/confxml.xml

sed -i 's#<auth start="false"users="root" passwordfile="/etc/rsync.pas"/>#<authstart="true" users="rsync_backup"passwordfile="/usr/local/sersync/passwd"/>#g' $sedir/confxml.xml
#!/bin/sh

sersync="/usr/local/sersync/sersync2"

confxml="/usr/local/sersync/confxml.xml"

status=$(ps aux |grep 'sersync2'|grep -v 'grep'|wc -l)

if [ $status -eq 0 ];

then

$sersync -d -r -o $confxml &

else

exit 0;

fi
