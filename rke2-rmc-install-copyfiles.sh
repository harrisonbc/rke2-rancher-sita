#!/usr/bin/env bash

# Set Up variables
set -a
source variables.env
set +a

# Prepare hosts
# Create directories on the target hosts

echo 
echo "Create required directories on the hosts."
echo "========================================="
echo

for i in $HOSTS; do ssh $HOST_USER@$i mkdir -p ~/suse/rancher/ ; done
for i in $HOSTS; do ssh $HOST_USER@$i sudo mkdir -p /etc/rancher/rke2/ /var/lib/rancher/rke2/server/manifests/ /var/lib/rancher/rke2/agent/images/ /opt/rke2/ ; done


# Copy files to the appropriate location on the 3 hosts

# config-1st.yaml & config.yaml
echo 
echo "Copy config.yaml to hosts."
echo "=========================="
echo

scp config-1st.yaml $HOST_USER@$HOST1:/tmp/config.yaml && ssh $HOST_USER@$HOST1 sudo cp /tmp/config.yaml /etc/rancher/rke2/config.yaml 
for i in $HOST23; do scp config.yaml $HOST_USER@$i:/tmp/config.yaml && ssh $HOST_USER@$i sudo cp /tmp/config.yaml /etc/rancher/rke2/config.yaml ; done

# Registries redirect file, registries.yaml
# echo 
# echo "Copy registries.yaml to hosts."
# echo "=============================="
# echo
# for i in $HOSTS; do scp registries.yaml $HOST_USER@$i:/tmp && ssh $HOST_USER@$i sudo cp /tmp/registries.yaml /etc/rancher/rke2/registries.yaml ; done

# Pod Security Admission config file, rancher-psa.yaml
# echo 
# echo "Copy rancher-psa.yaml to hosts."
# echo "==============================="
# echo
# for i in $HOSTS; do scp rancher-psa.yaml $HOST_USER@$i:/tmp && ssh $HOST_USER@$i sudo cp /tmp/rancher-psa.yaml /etc/rancher/rke2/rancher-psa.yaml ; done

# Calico config file rke2-calico-config.yaml
# echo 
# echo "Copy rke2-calico-config.yaml to hosts."
# echo "======================================"
# echo
# for i in $HOSTS; do scp rke2-calico-config.yaml $HOST_USER@$i:/tmp && ssh $HOST_USER@$i sudo cp /tmp/rke2-calico-config.yaml /var/lib/rancher/rke2/server/manifests/rke2-calico-config.yaml; done

# RKE2 Install script
echo 
echo "Copy RKE2 install script to hosts."
echo "=================================="
echo

for i in $HOSTS; do scp install.sh $HOST_USER@$i:~/suse/rancher; done

# RKE2 Proxy Config
echo 
echo "Copy RKE2 proxy config files to hosts."
echo "======================================"
echo

for i in $HOSTS; do scp rke2-server $HOST_USER@$i:/tmp/rke2-server && ssh $HOST_USER@$i sudo cp /tmp/rke2-server /etc/default/rke2-server; done
for i in $HOSTS; do scp rke2-agent  $HOST_USER@$i:/tmp/rke2-agent  && ssh $HOST_USER@$i sudo cp /tmp/rke2-agent  /etc/default/rke2-agent ; done

## Kube-VIP Manifests
# echo 
# echo "Copy Kube-VIP Manifests (Config & RBAC) to HOST1."
# echo "================================================="
# echo
#scp kube-vip.yaml $HOST_USER@$HOST1:/tmp && ssh $HOST_USER@$HOST1 sudo cp /tmp/kube-vip.yaml /var/lib/rancher/rke2/server/manifests/; done
#scp kube-vip-rbac.yaml $HOST_USER@$HOST1:/tmp && ssh $HOST_USER@$HOST1 sudo cp /tmp/kube-vip-rbac.yaml /var/lib/rancher/rke2/server/manifests/; done

# Reboot Nodes
echo 
echo "Reboot the 3 hosts."
echo "==================="
echo

for i in $HOSTS; do ssh $HOST_USER@$i sudo reboot ; done

# Install Required tools on Jump-Host
# In order to interact with the Kubernetes cluster from the command line, we need to install the kubectl command.
echo 
echo "Install kubectl command on jumphost."
echo "===================================="
echo

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
alias k=kubectl

# We can now install the kubernetes package manager
echo 
echo "Install helm command on jumphost."
echo "================================="
echo

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Wait for hosts to reboot
echo 
echo "Waiting for Hosts to reboot"
echo "==========================="
echo
