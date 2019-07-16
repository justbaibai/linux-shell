1、为什么所有RS上都要配置VIP因为当调度器把请求转发给对应RS时，并没有修改报文目的IP，因此请求报文目的IP仍为VIP，所以如果RS没有配置VIP，那么报文到达RS后就会被丢弃。
2、为什么所有RS要设置arp_ignore=1和arp_announce=2arp_ignore=1:只响应目的IP地址为接收网卡上的本地地址的arp请求因为我们在RS上都配置了VIP，因此此时是存在IP冲突的，当外部客户端向VIP发起请求时，会先发送arp请求，此时调度器和RS都会响应这个请求。如果某个RS响应了这个请求，则之后该客户端的请求就都发往该RS，并没有经过LVS，因此也就没有真正的负载均衡，LVS也就没有存在的意义。因此我们需要设置RS不响应对VIP的arp请求，这样外部客户端的所有对VIP的arp请求才会都解析到调度器上，然后经由LVS的调度器发往各个RS。系统默认arp_ignore=0，表示响应任意网卡上接收到的对本机IP地址的arp请求(包括环回网卡上的地址)，而不管该目的IP是否在接收网卡上。也就是说，如果机器上有两个网卡设备A和B，即使在A网卡上收到对B IP的arp请求，也会回应。而arp_ignore设置成1，则不会对B IP的arp请求进行回应。由于lo肯定不会对外通信，所以如果只有一个对外网口，其实只要设置这个对外网口即可，不过为了保险，很多时候都对all也进行设置。arp_announce=2:网卡在发送arp请求时使用出口网卡IP作为源IP当RS处理完请求，想要将响应发回给客户端，此时想要获取目的IP对应的目的MAC地址，那么就要发送arp请求。arp请求的目的IP就是想要获取MAC地址的IP，那arp请求的源IP呢？自然而然想到的是响应报文的源IP地址，但也不是一定是这样，arp请求的源IP是可以选择的，而arp_announce的作用正是控制这个地址如何选择。系统默认arp_announce=0，也就是源ip可以随意选择。这就会导致一个问题，如果发送arp请求时使用的是其他网口的IP，达到网络后，其他机器接收到这个请求就会更新这个IP的mac地址，而实际上并不该更新，因此为了避免arp表的混乱，我们需要将arp请求的源ip限制为出口网卡ip，因此需要设置arp_announce=2。
3、为什么RS上的VIP要配置在lo上由上可知，只要RS上的VIP不响应arp请求就可以了，因此不一定要配置在lo上，也可以配置在其他网口。由于lo设备不会直接接收外部请求，因此只要设置机器上的出口网卡不响应非本网卡上的arp请求接口。但是如果VIP配置在其他网口上，除了上面的配置，还需要配置该网口不响应任何arp请求，也就是arp_ignore要设置为8。
4、为什么RS上lo配置的VIP掩码为32位这是由于lo设备的特殊性导致， 如果lo绑定192.168.0.200/24，则该设备会响应该网段所有IP(192.168.0.1~192.168.0.254) 的请求，而不是只响应192.168.0.200这一个地址。
5、为什么调度器与RS要在同一网段中根据DR模式的原理，调度器只修改请求报文的目的mac，也就是转发是在二层进行，因此调度器和RS需要在同一个网段，从而ip_forward也不需要开启。
dr
ifconfig eth0:0 10.0.3.115 netmask 255.255.255.255 broadcast 10.0.3.115 up
ipvsadm -a -t 10.0.3.115:80 -r 10.0.3.167:80 -g

rs
ifconfig lo:0 10.0.3.115 netmask 255.255.255.255 broadcast 10.0.3.115 up
route add -host 10.0.3.115 dev lo
echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce
