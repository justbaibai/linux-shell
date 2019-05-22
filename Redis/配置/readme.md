配置分为简单，默认，通用，和网络中的生产环境可用 
* 简单：jiandan_redis.conf 拿着就能用
可以把变化的抽象出一个配置文件，把不变的定义成公共配置
在用include 包含进来  
比如说redis.conf  就可以包含redis-common.conf文件配置
