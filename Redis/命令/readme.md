/usr/local/redis/bin/redis-cli -h 10.0.3.118<br> 
auth baibai<br> 
/usr/local/redis/bin/redis-cli -h 10.0.3.118 -a baibai shutdown<br> 
常见命令

查看信息：info。

删除所有数据库内容：flushall。
刷新数据库：flushdb。
看所有键：KEYS *，使用select num可以查看键值数据。
设置变量：set test “who am i”。
config set dir dirpath 设置路径等配置。
config get dirfilename 获取路径及数据配置信息。
save 保存。
get 变量，查看变量名称。
