#!/bin/sh

# Install Docker from Ubuntu's repositories:
#apt-get update
#apt-get install -y docker.io

# or install Docker CE 18.06 from Docker's repositories for Ubuntu or Debian:

## Install prerequisites.
apt-get update && apt-get install -y apt-transport-https ca-certificates curl software-properties-common jq conntrack zsh zsh-syntax-highlighting

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

# Replace the .bashrc file with the original one, the new one jumbles things up
cp /etc/skel/.bashrc ~/

# Disable terminal timeout, similar to exec-timeout 0 0 on Cisco IOS
#echo "export TMOUT=0" >> ~/.bashrc
#echo "export TERM=xterm-256color" >> ~/.bashrc
#export TMOUT=0
#export TERM=xterm-256color

# Create .zshrc file for zsh
cat <<EOF >~/.zshrc
export TERM=linux
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
# kubectl not needed for workers/minions
#if [ $commands[kubectl] ]; then
#  source <(kubectl completion zsh)
#fi
PROMPT='%F{cyan}%n%f@%F{cyan}%m%f %F{red}%1~%f %# '
# The following two lines should be the last one in the .zshrc file
# zsh-syntax-highlighting should be at the end of this file
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
EOF

sudo chown $(id -u cisco):$(id -g cisco) $HOME/.zshrc
# Make zsh the default shell for cisco user
chsh -s $(which zsh) cisco
zsh
export TERM=linux
