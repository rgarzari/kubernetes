#!/bin/sh
# run this script as sudo, for example:
# sudo ./kubemaster.sh

# Install Docker from Ubuntu's repositories:
#apt-get update
#apt-get install -y docker.io

# or install Docker CE 18.06 from Docker's repositories for Ubuntu or Debian:

## Install prerequisites.
apt-get update && apt-get install -y apt-transport-https ca-certificates curl software-properties-common

## Download GPG key.
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

## Add docker apt repository.
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

## Install docker.
apt-get update && apt-get install -y docker-ce=18.06.0~ce~3-0~ubuntu

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
systemctl daemon-reload
systemctl restart docker


apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

apt-get update

# Used for flannel to pass bridged IPv4 traffic to iptables’ chains
sysctl net.bridge.bridge-nf-call-iptables=1

# Verify connectivity to gcr.io registries
kubeadm config images pull

# Initialize the master
kubeadm init --apiserver-advertise-address=10.0.0.2 --pod-network-cidr=10.244.0.0/16

# Add env variable
export KUBECONFIG=/etc/kubernetes/admin.conf

# Copy the admin.conf file into $HOME/.kube/config
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install flannel - Might comment this one out for the lab so that the students
# know how flannel is installed
sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml

# Replace the .bashrc file with the original one, the new one jumbles things up
cp /etc/skel/.bashrc ~/