#!/bin/sh
yum install -y pcre-devel wget openssl-devel openssl zlib-devel  gcc gcc-c++ dos2unix
wget -P /usr/local/src/  http://nginx.org/download/nginx-1.14.1.tar.gz
useradd -s /sbin/nologin -M nginx
cd /usr/local/src/ && tar xf nginx-1.14.1.tar.gz
sed -i 's@#define NGINX_VERSION.*$@#define NGINX_VERSION      "8.8.8"@' /usr/local/src/nginx-1.14.1/src/core/nginx.h
sed -i 's@#define NGINX_VER.*NGINX_VERSION$@#define NGINX_VER          "baibai/" NGINX_VERSION@' /usr/local/src/nginx-1.14.1/src/core/nginx.h
sed -i 's@Server: nginx@Server: baibai@' /usr/local/src/nginx-1.14.1/src/http/ngx_http_header_filter_module.c
cd /usr/local/src/nginx-1.14.1 && ./configure --prefix=/usr/local/nginx-1.14.1 --user=nginx --group=nginx --with-http_stub_status_module --with-http_v2_module --with-http_ssl_module --with-http_gzip_static_module --with-http_realip_module --with-http_flv_module --with-http_mp4_module  --with-pcre --with-pcre-jit
make && make install ||exit 1
sleep 3
echo "install nginx is ok"
ln -s /usr/local/nginx-1.14.1/  /usr/local/nginx
