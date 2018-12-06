#!/bin/sh
# run this script as sudo, for example:
# sudo ./kubemaster.sh

# Install Docker from Ubuntu's repositories:
#apt-get update
#apt-get install -y docker.io

# or install Docker CE 18.06 from Docker's repositories for Ubuntu or Debian:

## Install prerequisites.
apt-get update && apt-get install -y apt-transport-https ca-certificates curl software-properties-common jq conntrack zsh

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


# apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet=1.12.2-00 kubeadm=1.12.2-00 kubectl=1.12.2-00
apt-mark hold kubelet kubeadm kubectl

apt-get update

# Used for flannel to pass bridged IPv4 traffic to iptables’ chains
sysctl net.bridge.bridge-nf-call-iptables=1

# Verify connectivity to gcr.io registries
kubeadm config images pull --kubernetes-version=v1.12.2

# Initialize the master
kubeadm init --apiserver-advertise-address=10.0.0.2 --pod-network-cidr=10.244.0.0/16  --kubernetes-version=v1.12.2

# Add env variable
export KUBECONFIG=/etc/kubernetes/admin.conf

# Copy the admin.conf file into $HOME/.kube/config
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# Change permission for .kube/config file for the cisco user to use kubectl, otherwise, kubectl commands need to be executed with sudo 
sudo chown $(id -u cisco):$(id -g cisco) $HOME/.kube/config

# Install flannel - Might comment this one out for the lab so that the students
# know how flannel is installed
# sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml
sudo kubectl apply -f https://raw.githubusercontent.com/rgarzari/kubernetes/master/kube-flannel.yml

# Replace the .bashrc file with the original one, the new one jumbles things up
cp /etc/skel/.bashrc ~/

# Disable terminal timeout, similar to exec-timeout 0 0 on Cisco IOS
#echo "export TMOUT=0" >> ~/.bashrc
#echo "export TERM=xterm-256color" >> ~/.bashrc
#export TMOUT=0
#export TERM=xterm-256color

# Create .zshrc file for zsh
touch ~/.zshrc
echo "export TERM=linux" >> ~/.zshrc
echo "ls --color=auto" >> ~/.zshrc
# Make zsh the default shell for cisco user
chsh -s $(which zsh) cisco
zsh
export TERM=linux
