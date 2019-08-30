1按下键盘TAB键将最下面的vmlinuz initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 rd.live.check quiet 改为 vmlinuz initrd=initrd.img linux dd quiet

2查看U盘启动盘的名称比如：sda，sdb，sdc  ps：label一列会显示Centos7等字样的

3重启后到第三步界面按下TAB键
    
4将vmlinuz initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 rd.live.check quiet  改为  vmlinuz initrd=initrd.img inst.stage2=hd:/dev/sdb1 quiet   ps：sdb1就是你看到的启动盘名称

5别忘了net.ifnames=0 biosdevname=0 


32G 内存配置示例：

```
<Connector port="8080" protocol="HTTP/1.1"
               connectionTimeout="20000" maxThreads="1000" minSpareThreads="60" maxSpareThreads="600"  acceptCount="120"
               redirectPort="8443" URIEncoding="utf-8"/>
```
