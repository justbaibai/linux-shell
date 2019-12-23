create database mm_wiki;
grant all privileges on mm_wiki.* to baibai@'127.0.0.1' identified by 'baibai';
wget https://github.com/phachon/mm-wiki/releases/download/v0.1.4/mm-wiki-v0.1.4-linux-amd64.tar.gz -P /usr/local/src/
./install --port=80
http://ip

nohup ./mm-wiki --conf conf/mm-wiki.conf&
