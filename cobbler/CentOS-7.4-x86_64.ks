lang en_US
keyboard us
text
timezone --utc Asia/Shanghai
rootpw  --iscrypted $default_password_crypted
text
install
url --url=$tree
bootloader --location=mbr
zerombr
clearpart --all --initlabel
part /boot --fstype xfs --size 200 --ondisk sda
part swap --size 1024 --ondisk sda
part / --fstype xfs --size 1 --grow --ondisk sda
$SNIPPET('network_config')
reboot
firewall --disabled
# Network information
$SNIPPET('network_config')
selinux --disabled
skipx
%pre
$SNIPPET('log_ks_pre')
$SNIPPET('kickstart_start')
$SNIPPET('pre_install_network_config')
# Enable installation monitoring
$SNIPPET('pre_anamon')
%end
%packages
@base
@core
tree
nmap
sysstat
lrzsz
dos2unix
telnet
iptraf
ncurses-devel
openssl-devel
zlib-devel
OpenIPMI-tools
screen
%end
%post
systemctl disable postfix.service
%end




