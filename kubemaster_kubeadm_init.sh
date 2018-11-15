#!/bin/sh

# Initialize the master
kubeadm init --apiserver-advertise-address=10.0.0.2 --pod-network-cidr=10.244.0.0/16

# Add env variable
export KUBECONFIG=/etc/kubernetes/admin.conf

# Exit root
exit

# Copy the admin.conf file into $HOME/.kube/config
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install flannel - Might comment this one out for the lab so that the students
# know how flannel is installed
sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml
