#!/usr/bin/sh
egrep '(svm|vmx)' /proc/cpuinfo
yum install qemu-kvm libvirt virt-install bridge-utils -y
cd /etc/sysconfig/network-scripts
cp ifcfg-eth0 ifcfg-br0
#ifcfg-eth0 修改，注释掉IP、GATEWAY、NETMASK
sed -i 's/^IPADDR=/#IPADDR=/g' ifcfg-eth0
sed -i 's/^GATEWAY/#GATEWAY/g' ifcfg-eth0
sed -i 's/^IPADDR=/#IPADDR=/g' ifcfg-eth0
echo BRIDGE="br0">>ifcfg-eth0
#ifcfg-br0 修改，改名称、驱动绑定
sed -i 's/TYPE="Ethernet"/TYPE="Bridge"/g' ifcfg-br0
sed -i 's/DEVICE="eth0"/DEVICE="br0"/g' ifcfg-br0
sed -i 's/NAME="eth0"/NAME="br0"/g' ifcfg-br0
sed -i 's/^UUID=/#UUID=/g' ifcfg-br0
sed -i 's/^HWADDR=/#HWADDR=/g' ifcfg-br0

yum -y install git python-pip libvirt-python libxml2-python python-websockify python-devel
pip install numpy
git clone git://github.com/retspen/webvirtmgr.git
cd webvirtmgr/



user  nginx nginx;
worker_processes  auto;
worker_cpu_affinity auto;
error_log /usr/local/nginx/logs/error.log error;
pid        /usr/local/nginx/logs/nginx.pid;
worker_rlimit_nofile 65535;
events {
    use epoll;
    worker_connections  65535;
}

#user  nobody;
#worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


#events {
#    worker_connections  1024;
#}


http {
    include       mime.types;
    default_type  application/octet-stream;
     client_header_buffer_size 4k;
    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;
     charset utf-8;
    server_names_hash_bucket_size 128;
    large_client_header_buffers 4 64k;
    client_max_body_size 6200m;
    sendfile on;
    tcp_nodelay on;
    gzip on;
    gzip_min_length  1k;
    gzip_buffers  4 32k;
    gzip_http_version  1.1;
    gzip_comp_level  4;
    gzip_types text/plain application/x-javascript text/css application/xml;
    gzip_disable "MSIE [1-6]\.";
    gzip_vary on;

     log_format json '{"timestamp":"$time_iso8601",'
                 '"server_addr":"$server_addr",'
                 '"remote_addr":"$remote_addr",'
                 '"body_bytes_sent":$body_bytes_sent,'
                 '"status":"$status",'
                 '"request":"$request",'
                 '"url":"$uri",'
                 '"http_referer":"$http_referer",'
                 '"request_time":$request_time,'
                 '"upstream_response_time":"$upstream_response_time",'
                 '"upstream_addr":"$upstream_addr",'
                 '"upstream_status":"$upstream_status",'
                 '"http_user_agent":"$http_user_agent" }';

     access_log /var/log/nginx/access.log json;

   # sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  3600;

    #gzip  on;

    server {
        listen       80;
        server_name  localhost;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;
        location /static/ {
        root /usr/local/src/webvirtmgr/webvirtmgr;
        expires max;
    }
        location / {
            #root   html;
            #index  index.html index.htm;
	    proxy_pass http://127.0.0.1:8000;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-for $proxy_add_x_forwarded_for;
        proxy_set_header Host $host:$server_port;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 6000;
        proxy_read_timeout 6000;
        proxy_send_timeout 6000;
        client_max_body_size 6240M;
        }

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
        #
        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        #location ~ \.php$ {
        #    root           html;
        #    fastcgi_pass   127.0.0.1:9000;
        #    fastcgi_index  index.php;
        #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
        #    include        fastcgi_params;
        #}

        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        #location ~ /\.ht {
        #    deny  all;
        #}
    }


    # another virtual host using mix of IP-, name-, and port-based configuration
    #
    #server {
    #    listen       8000;
    #    listen       somename:8080;
    #    server_name  somename  alias  another.alias;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}


    # HTTPS server
    #
    #server {
    #    listen       443 ssl;
    #    server_name  localhost;

    #    ssl_certificate      cert.pem;
    #    ssl_certificate_key  cert.key;

    #    ssl_session_cache    shared:SSL:1m;
    #    ssl_session_timeout  5m;

    #    ssl_ciphers  HIGH:!aNULL:!MD5;
    #    ssl_prefer_server_ciphers  on;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}






pip install -r requirements.txt

 ./manage.py collectstatic
  ./manage.py syncdb
  # ./manage.py createsuperuser #添加管理员账号
# ./manage.py changepassword kvm #修改用户kvm的密码

mkdir /var/log/nginx/

  chown -R nginx:nginx /usr/local/src/webvirtmgr

  nohup /usr/bin/python /usr/local/src/webvirtmgr/manage.py run_gunicorn 127.0.0.1:8000 &
   nohup /usr/bin/python /usr/local/src/webvirtmgr/console/webvirtmgr-console &

    ssh-keygen -t rsa
    ssh-copy-id 10.0.3.163


在kvm中，安装windows需要VirtIO模式这个选项的对号去掉   就是创建实例的时候。
