NMI watchdog: BUG: soft lockup - CPU#0 stuck for 24s! [chronyd:500]
网上找的不一定好使   
起因  

近期在服务器跑大量高负载程序，造成cpu soft lockup。如果确认不是软件的问题。
解决办法:
#追加到配置文件中
echo 30 > /proc/sys/kernel/watchdog_thresh 
#查看
[root@git-node1 data]# tail -1 /proc/sys/kernel/watchdog_thresh
30
#临时生效
sysctl -w kernel.watchdog_thresh=30
#内核软死锁（soft lockup）bug原因分析
Soft lockup名称解释：所谓，soft lockup就是说，这个bug没有让系统彻底死机，但是若干个进程（或者kernel thread）被锁死在了某个状态（一般在内核区域），很多情况下这个是由于内核锁的使用的问题。




软件看门狗分为两种，用于检测soft lockup的普通软狗(基于时钟中断)，以及检测hard lockup的NMI狗（基于NMI中断）。
注1：时钟中断优先级小于NMI中断 
注2：lockup，是指某段内核代码占着CPU不放。Lockup严重的情况下会导致整个系统失去响应。 
soft lockup 和 hard lockup，它们的唯一区别是 hard lockup 发生在CPU屏蔽中断的情况下。
软狗
单个cpu检测线程是否正常调度。
一般软狗的正常流程如下（假设软狗触发的时间为20s）
<img src="https://github.com/justbaibai/linux-shell/blob/master/img/20170430170428338.png">


可能产生软狗的原因： 
1.频繁处理硬中断以至于没有时间正常调度 
2.长期处理软中断 
3.对于非抢占式内核，某个线程长时间执行而不触发调度 
4.以上all

NMI watchdog
单个CPU检测中断是否能够正常上报 
当CPU处于关中断状态达到一定时间会被判定进入hard lockup

<img src="https://github.com/justbaibai/linux-shell/blob/master/img/20170430170510093.png">



可能产生NMI狗的原因： 
1.长期处理某个硬中断 
2.长时间在禁用本地中断下处理

NMI狗机制也是用一个percpu的hrtimer来喂狗，为了能够及时检测到hard lockup状态，在比中断优先级更高的NMI上下文进行检测。
