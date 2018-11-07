#!/bin/sh

# Verify connectivity to gcr.io registries
kubeadm config images pull

# Initialize the master
kubeadm init --apiserver-advertise-address=10.0.0.1 --pod-network-cidr=10.244.0.0/16

#Add env variable
export KUBECONFIG=/etc/kubernetes/admin.conf
