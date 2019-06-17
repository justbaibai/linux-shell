###那些年我们为面试做的准备

inode block
假设XXX产生的日志文件名为access_log,在XXX正在运行时,执行命令mv access_log access_log.bak,执行完后,请问新的XXX的日志会打印到哪里?
新的日志会在access_log.bak中,因为XXX启动时会找access_log文件，随时准备向文件中加入日志信息,虽然此时文件被改名，但是由于服务正在运行,因为它的inode节点的位置没有变,程序打开的fd仍然会指向原来那个inode
不会因为文件名的改变而改变.XXX会继续向已改名的文件中追加日志，但是若重启apache服务，系统会检查access_log文件是否存在，若不存在则创建.
在XXX运行时  rm -fr access_log  空间不会释放   正确的是>access_log  重定向  清空日志而不是在运行中删除日志
ln 软硬链接
软链接可以跨文件系统 ，硬链接不可以。软链接可以对目录进行链接，硬链接不可以。
区别:
软链接文件的大小和创建时间和源文件不同。软链接文件只是维持了从软链接到源文件的指向关系（从jys.soft->jys可以看出），不是源文件的内容，大小不一样容易理解。
硬链接文件和源文件的大小和创建时间一样。硬链接文件的内容和源文件的内容一模一样，相当于copy了一份。


简单awk
在Shell环境下,如何查看远程Linux系统运行了多少时间?
uptime | awk '{print $3}'
简单的几个命令
uptime   w last


处理以下文件内容,将域名取出并进行计数排序,如处理: http://www.baidu.com/more/
http://www.baidu.com/guding/more.html
http://www.baidu.com/events/20060105/photomore.html
http://hi.baidu.com/browse/
http://www.sina.com.cn/head/www20021123am.shtml
http://www.sina.com.cn/head/www20041223am.shtml

得到如下结果:
域名的出现的次数 域名
3 www.baidu.com
2 www.sina.com.cn
1 hi.baidu.co 百度总喜欢这种题目,我上篇日志的site inurl也是,这个是统计域名的,还有一个说是统计文件名的,就是后面的index没有的就直接为空,这个用shell怎么实现还在思考中,想出来了再写
cat file | sed -e ' s/http:\/\///' -e ' s/\/.*//' |  uniq -c | sort -rn
awk -F/ '{print $3}' file |uniq -c | sort -r |awk '{print $1"\t",$2}'



180.153.205.103 - - [03/Jul/2013:15:13:59 +0800] GET /wp-login.php?redirect_to=http%3A%2F%2Fdemo.catjia.com%2Fwp-admin%2Foptions-general.php&reauth=1 HTTP/1.1 200 2269 - Mozilla/4.0 -
101.226.51.227 - - [03/Jul/2013:15:14:07 +0800] GET /wp-admin/options-general.php?settings-updated=true HTTP/1.1 302 0 - Mozilla/4.0 -
101.226.51.227 - - [03/Jul/2013:15:14:07 +0800] GET /wp-login.php?redirect_to=http%3A%2F%2Fdemo.catjia.com%2Fwp-admin%2Foptions-general.php%3Fsettings-updated%3Dtrue&reauth=1 HTTP/1.1 200 2291 - Mozilla/4.0 -


统计
awk '{a[$1]+=1;} END {for(i in a){print a[i]" "i;}}' log/visit.log
2 180.153.205.103
10 101.226.33.200
1 180.153.114.199
1 113.110.176.131
2 101.226.51.227


对统计结果排序
awk '{a[$1]+=1;} END {for(i in a){print a[i]" "i;}}' log/visit.log | sort
1 113.110.176.131
1 180.153.114.199
10 101.226.33.200
2 101.226.51.227
2 180.153.205.103


sort默认是升序的，10竟然没有排在最后，原来sort默认对一行的首字母进行排序
需要加入其它参数 -t 指定分隔符 -k 指定列 -g 按照常规数值排序 -n 根据字符串数值比较
awk '{a[$1]+=1;} END {for(i in a){print a[i]" "i;}}' log/visit.log | sort -t " " -k 1 -n
1 113.110.176.131
1 180.153.114.199
2 101.226.51.227
2 180.153.205.103
10 101.226.33.200


改为降序 -r
awk '{a[$1]+=1;} END {for(i in a){print a[i]" "i;}}' log/visit.log | sort -t " " -k 1 -n -r
10 101.226.33.200
2 180.153.205.103
2 101.226.51.227
1 180.153.114.199
1 113.110.176.131

告诉我那些是进程后又问如何查看一个进程所使用的文件句柄？

/proc/进程号/fd/的个数就行了

ps aux | grep “nginx” | grep -v “grep” | wc -l

/proc/sys 子目录的作用

该子目录的作用是报告各种不同的内核参数，并让您能交互地更改其中的某些。与 /proc 中所有其他文件不同，该目录中的某些文件可以写入

sed '$!N;s/\n/ /g' test^C
[root@kvm ~]# sed ':a;N;$!ba;s/\n/ /g' test

sed 删除换行符

sed ':label;N;s/\n/:/;b label' filename
sed ':label;N;s/\n/:/;t label' filename


上面的两条命令可以实现将文件中的所有换行符替换为指定的字串，如命令中的冒号。命令的解释：

:label;  这是一个标签，用来实现跳转处理，名字可以随便取(label),后面的b label就是跳转指令
N;  N是sed的一个处理命令，追加文本流中的下一行到模式空间进行合并处理，因此是换行符可见
s/\n/:/;   s是sed的替换命令，将换行符替换为冒号
b label  或者 t label    b / t 是sed的跳转命令，跳转到指定的标签处



tr "\n" " " < file.txt

a.将所有奇数行和偶数行合并,就是去奇数行的换行符了哦

sed ‘$!N;s/\n/ /g’ test
b.就是去第二行的了哦

sed -n -e 2p -e 3p test ｜ sed ‘$!N;s/\n/ /g’ test
