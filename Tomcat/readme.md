再看！
再最前面加就行

在一些规模稍大的应用中，Java虚拟机（JVM）的内存设置尤为重要，想在项目中取得好的效率，GC（垃圾回收）的设置是第一步。

PermGen space：全称是Permanent Generation space.就是说是永久保存的区域,用于存放Class和Meta信息,Class在被Load的时候被放入该区域Heap space：存放Instance。

GC(Garbage Collection)应该不会对PermGen space进行清理,所以如果你的APP会LOAD很多CLASS的话,就很可能出现PermGen space错误

Java Heap分为3个区
1.Young
2.Old
3.Permanent

Young保存刚实例化的对象。当该区被填满时，GC会将对象移到Old区。Permanent区则负责保存反射对象，本文不讨论该区。

JVM的Heap分配可以使用-X参数设定，

-Xms 
初始Heap大小

-Xmx 
java heap最大值 

-Xmn 
young generation的heap大小

JVM有2个GC线程
第一个线程负责回收Heap的Young区
第二个线程在Heap不足时，遍历Heap，将Young 区升级为Older区

Older区的大小等于-Xmx减去-Xmn，不能将-Xms的值设的过大，因为第二个线程被迫运行会降低JVM的性能。
为什么一些程序频繁发生GC？

有如下原因：
1.程序内调用了System.gc()或Runtime.gc()。
2.一些中间件软件调用自己的GC方法，此时需要设置参数禁止这些GC。
3.Java的Heap太小，一般默认的Heap值都很小。
4.频繁实例化对象，Release对象 此时尽量保存并重用对象，例如使用StringBuffer()和String()。

如果你发现每次GC后，Heap的剩余空间会是总空间的50%，这表示你的Heap处于健康状态,许多Server端的Java程序每次GC后最好能有65%的剩余空间

经验之谈：

1．Server端JVM最好将-Xms和-Xmx设为相同值。为了优化GC，最好让-Xmn值约等于-Xmx的1/3。
2．一个GUI程序最好是每10到20秒间运行一次GC，每次在半秒之内完成。

注意：

1．增加Heap的大小虽然会降低GC的频率，但也增加了每次GC的时间。并且GC运行时，所有的用户线程将暂停，也就是GC期间，Java应用程序不做任何工作。
2．Heap大小并不决定进程的内存使用量。进程的内存使用量要大于-Xmx定义的值，因为Java为其他任务分配内存，例如每个线程的Stack等。

Stack的设定
每个线程都有他自己的Stack。

-Xss 
每个线程的Stack大小

Stack的大小限制着线程的数量。如果Stack过大就好导致内存溢漏。-Xss参数决定Stack大小，例如-Xss1024K。如果Stack太小，也会导致Stack溢漏。

 

主要通过以下的几个jvm参数来设置堆内存的： 

-Xmx512m	最大总堆内存，一般设置为物理内存的1/4
-Xms512m	初始总堆内存，一般将它设置的和最大堆内存一样大，这样就不需要根据当前堆使用情况而调整堆的大小了
-Xmn192m	年轻带堆内存，sun官方推荐为整个堆的3/8
堆内存的组成	总堆内存 = 年轻带堆内存 + 年老带堆内存 + 持久带堆内存
年轻带堆内存	对象刚创建出来时放在这里
年老带堆内存	对象在被真正会回收之前会先放在这里
持久带堆内存	class文件，元数据等放在这里
-XX:PermSize=128m	持久带堆的初始大小
-XX:MaxPermSize=128m	持久带堆的最大大小，eclipse默认为256m。如果要编译jdk这种，一定要把这个设的很大，因为它的类太多了。


32G 内存配置示例：

JAVA_OPTS="$JAVA_OPTS  -Xms10g -Xmx10g -XX:PermSize=1g -XX:MaxPermSize=2g -Xshare:off -Xmn1024m


32G 内存配置示例：

<Connector port="8080" protocol="HTTP/1.1"
               connectionTimeout="20000" maxThreads="1000" minSpareThreads="60" maxSpareThreads="600"  acceptCount="120"
               redirectPort="8443" URIEncoding="utf-8"/>
