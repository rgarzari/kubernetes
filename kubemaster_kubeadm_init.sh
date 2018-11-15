#!/bin/sh

# Initialize the master
kubeadm init --apiserver-advertise-address=10.0.0.2 --pod-network-cidr=10.244.0.0/16

#Add env variable
export KUBECONFIG=/etc/kubernetes/admin.conf
