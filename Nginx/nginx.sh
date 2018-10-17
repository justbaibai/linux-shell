 yum install pcre-devel lrzsz wget openssl-devel openssl zlib-devel -y
 yum install gcc gcc-c++
 useradd -s /sbin/nologin -M nginx
 #不让nginx登陆不创建家目录  主进程是root启的  子进程用
 nginx -V 看以前编译的参数   -v看nginx版本 
 #必要的的前期准备   一般nginx并发都很大   他不是瓶颈   主要是数据库  他可以水平扩展  
 
 wget https://nginx.org/download/nginx-1.14.0.tar.gz
 #选择稳定版 的一版是偶数  奇数是开发版   看一下CHANGES  接下来就是编译参数  如果有旧版的看一CVE  我记得 /XX.jpg/XX.php 图片一定存在  后面的.php 不一定存在 XX.jpg%00.php这个跟php版本有关   没事的时候看看尹毅的代码审计 
 tar xf  nginx-1.14.0.tar.gz
 cd nginx-1.14.0
 ./configure --prefix=/usr/local/nginx-1.14.0 --user=nginx --group=nginx --with-http_stub_status_module --with-http_v2_module --with-http_ssl_module --with-http_gzip_static_module --with-http_realip_module --with-http_flv_module --with-http_mp4_module  --with-pcre --with-pcre-jit 
 cd /usr/local/
 ln -s nginx-1.14.0 nginx
 nginx -t 
 #检查语法
 make&&make install
 
