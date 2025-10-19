#!/bin/bash
set -e

# Initialize Kubernetes control plane
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 | tee /tmp/kubeadm-init.log

# Configure kubectl for ubuntu user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Flannel CNI
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# Save join command for workers
kubeadm token create --print-join-command | sudo tee /tmp/join-command.sh
