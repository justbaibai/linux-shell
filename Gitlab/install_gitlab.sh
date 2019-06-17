#!/bin/sh
yum install -y git
git clone https://gitlab.com/xhang/gitlab.git
cat gitlab/VERSION  #11.5.6 安装相同版本的
yum install -y curl openssh-server openssh-clients postfix cronie policycoreutils-python
gitlab_version=$(cat gitlab/VERSION)
wget https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/gitlab-ce-${gitlab_version}-ce.0.el7.x86_64.rpm
rpm -ihv gitlab-ce-${gitlab_version}-ce.0.el7.x86_64.rpm
gitlab-ctl reconfigure
sed -i "s#external_url\s'http://gitlab.example.com'#external_url 'http://10.0.3.64'#g" /etc/gitlab/gitlab.rb
gitlab-ctl reconfigure
gitlab-ctl restart
gitlab-ctl stop
#head -1 /opt/gitlab/version-manifest.txt
cd /root/gitlab
git diff v${gitlab_version} v${gitlab_version}-zh > ../${gitlab_version}-zh.diff
yum install patch -y
cd /root
patch -d /opt/gitlab/embedded/service/gitlab-rails -p1 < ${gitlab_version}-zh.diff #一顿回车
gitlab-ctl start
gitlab-ctl reconfigure

gitlab修改用户密码
>sudo gitlab-rails console production

> user=User.where(name: "root").first

> user.password=12345678

> user.save!

> quit
