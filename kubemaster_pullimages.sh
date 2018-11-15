#!/bin/sh

# Verify connectivity to gcr.io registries
kubeadm config images pull
