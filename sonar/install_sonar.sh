 wget -P /usr/local/src/  https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-7.9.1.zip
7.9 以下可以用  mysql 7.9是长期支持版本但不支持mysql

我用的是7.7的
 useradd sonar
 passwd sonar
sysctl -w  vm.max_map_count=262144
sysctl -w fs.file-max=65536

 CREATE DATABASE sonar DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
  CREATE USER 'sonar' IDENTIFIED BY 'sonar';
   GRANT ALL ON sonar.* TO 'sonar'@'%' IDENTIFIED BY 'sonar';
GRANT ALL ON sonar.* TO 'sonar'@'localhost' IDENTIFIED BY 'sonar';
   FLUSH PRIVILEGES;
   jdk
   yum install -y java-1.8.0-openjdk-devel.x86_64

   sonar.jdbc.username=sonar
   sonar.jdbc.password=sonar
   sonar.jdbc.url=jdbc:mysql://xxx.xxx.xxx.xxx:3306/sonar?useUnicode=true&characterEncoding=utf8&rewriteBatchedStatements=true&useConfigs=maxPerformance
conf/

7.9的
<-- Wrapper Stopped
11jdk

[root@localhost ~]# adduser qube
[root@localhost ~]# passwd qube
echo 262144 >/proc/sys/vm/max_map_count

扫描器
sonarscanner
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.0.0.1744-linux.zip
