#!/bin/sh
yum install ntpdate -y
ntpdate time.windows.com
#集群同步时间
vim /etc/hosts
scp /etc/hosts root@10.0.3.211:/etc/hosts
scp /etc/hosts root@10.0.3.212:/etc/hosts
ping node1
ping node2
#集群互相解析

modprobe br_netfilter
echo -e 'net.bridge.bridge-nf-call-iptables = 1 \nnet.bridge.bridge-nf-call-ip6tables = 1' >> /etc/sysctl.conf  && sysctl -p


wget -P /etc/yum.repos.d/ https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo


cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
yum repolist


lsmod|grep ip_vs
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4

grep -e ipvs -e nf_conntrack_ipv4 /lib/modules/$(uname -r)/modules.builtin

yum install ipset -y
yum install ipvsadm -y

cat /etc/docker/daemon.json
mkdir -p /etc/docker
vim /etc/docker/daemon.json
{
  "registry-mirrors": [
    "https://registry.docker-cn.com"
  ]
}

cat >> /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF



#第一个警告 上 第二个是swap没关  第三个docker版本高了
[WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
[WARNING Swap]: running with swap on is not supported. Please disable swap
[WARNING SystemVerification]: this Docker version is not on the list of validated versions: 19.03.4. Latest validated version: 18.09







yum install  kubelet kubeadm kubectl docker-ce -y
1.16.2-0
systemctl enable  kubelet docker
vim /etc/sysconfig/kubelet
"--fail-swap-on=false"
kubeadm init --kubernetes-version=v1.16.2 --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/12 --apiserver-advertise-address=10.0.3.70 --ignore-preflight-errors=Swap
error execution phase preflight: [preflight] Some fatal errors occurred:
	[ERROR ImagePull]: failed to pull image k8s.gcr.io/kube-apiserver:v1.16.2: output: Error response from daemon: Get https://k8s.gcr.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
, error: exit status 1
	[ERROR ImagePull]: failed to pull image k8s.gcr.io/kube-controller-manager:v1.16.2: output: Error response from daemon: Get https://k8s.gcr.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
, error: exit status 1
	[ERROR ImagePull]: failed to pull image k8s.gcr.io/kube-scheduler:v1.16.2: output: Error response from daemon: Get https://k8s.gcr.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
, error: exit status 1
	[ERROR ImagePull]: failed to pull image k8s.gcr.io/kube-proxy:v1.16.2: output: Error response from daemon: Get https://k8s.gcr.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
, error: exit status 1
	[ERROR ImagePull]: failed to pull image k8s.gcr.io/pause:3.1: output: Error response from daemon: Get https://k8s.gcr.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
, error: exit status 1
	[ERROR ImagePull]: failed to pull image k8s.gcr.io/etcd:3.3.15-0: output: Error response from daemon: Get https://k8s.gcr.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
, error: exit status 1
	[ERROR ImagePull]: failed to pull image k8s.gcr.io/coredns:1.6.2: output: Error response from daemon: Get https://k8s.gcr.io/v2/: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
, error: exit status 1
[preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`
To see the stack trace of this error execute with --v=5 or higher

docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.16.2
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.16.2
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.16.2
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.16.2
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.6.2
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.3.15-0
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.16.2    k8s.gcr.io/kube-apiserver:v1.16.2
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.16.2    k8s.gcr.io/kube-controller-manager:v1.16.2
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.16.2  k8s.gcr.io/kube-scheduler:v1.16.2
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.16.2  k8s.gcr.io/kube-proxy:v1.16.2
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1   k8s.gcr.io/pause:3.1
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.3.15-0 k8s.gcr.io/etcd:3.3.15-0
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.6.2  k8s.gcr.io/coredns:1.6.2


Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:
#执行这个
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 10.0.3.70:6443 --token 6sl24w.21lpwayxsfwpdjxr \
    --discovery-token-ca-cert-hash sha256:9694d7afa386bafeaa565191703ec9a590d63f7bbc73ddd2885bc2cd2d2387ab


    kubeadm join 10.0.3.70:6443 --token gkp17v.pr45wqf41vo3v94y \
        --discovery-token-ca-cert-hash sha256:f7fda50e121150fc05e62a3081511c56e972395ef1b1b4d815bb2071ce0293c9



master kubelet: W1030 14:42:08.487574   24120 cni.go:237] Unable to update cni config: no networks found in /etc/cni/net.d
master kubelet: E1030 14:42:10.181412   24120 kubelet.go:2187] Container runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:docker: network plugin is not ready: cni config uninitialized

 kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
wget  https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
 如果不行就
 #不好使
# https://github.com/coreos/flannel/releases
 #docker pull registry.cn-hangzhou.aliyuncs.com/kuberimages/flannel:v0.10.0-amd64
 #docker tag registry.cn-hangzhou.aliyuncs.com/kuberimages/flannel:v0.10.0-amd64  k8s.gcr.io/flannel:v0.10.0-amd64


node
yum install  kubelet kubeadm docker-ce -y
systemctl enable  kubelet docker
systemctl start  kubelet docker


echo "1" >/proc/sys/net/bridge/bridge-nf-call-iptables
swapoff -a

docker save -o mynode.gz  k8s.gcr.io/kube-proxy:v1.16.2 quay.io/coreos/flannel:v0.11.0-amd64 k8s.gcr.io/pause:3.1
scp mynode.gz root@node1:/root/
kubectl get nodes
scp mynode.gz root@node2:/root/
kubectl get nodes
docker  load <mynode.gz
