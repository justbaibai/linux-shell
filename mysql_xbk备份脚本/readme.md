backup_gzip

│   ├── full_2020-01-14-15-54-16.tar.gz

│   └── incr0_2020-01-14-15-57-56.tar.gz

├── bak

│   ├── full

│   │  

├── bin

│   └── backup_xb.sh

├── conf

│   ├── backup.conf

│   └── test.sh

├── log

│   └── xtrabackup_time.txt

└── temp

    ├── 2020-01-14-15-54-16-tempfile.txt
    
    ├── 2020-01-14-15-57-56-tempfile.txt
    
    ├── baibai.txt
    
    ├── last_del_old.log
    
    ├── lock.txt
    
    ├── tempfile.txt
    
    └── test.txt
    
0 0 * * * sh /root/test/bin/backup_xb.sh >/dev/null 2>&1

默认7天为一个周期 一个全备 6 个增量  压缩文件可以定义删除时间  根据情况都可以修改

用着还行 可能体量比较小  但比mysqldunp 好用  在网上看了看  自己有填了点  感觉还行。

目录自动生成 上面是简单的结构

