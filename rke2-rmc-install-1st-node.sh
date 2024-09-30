#!/usr/bin/env bash

# Set Up variables
set -a
source variables.env
set +a

# Create First Node
echo 
echo "Install RKE2 on First Node."
echo "==========================="
echo

ssh $HOST_USER@$HOST1 sudo INSTALL_RKE2_VERSION=$RKE2_VERSION ~/suse/rancher/install.sh

# Perform CIS 1.23 Hardening Actions on 1st Node (Create etcd user & group, copy config file to correct location)
# echo 
# echo "Perform CIS Hardening steps on First Node."
# echo "=========================================="
# echo
# ssh $HOST_USER@$HOST1 'sudo useradd -r -c "etcd user" -s /sbin/nologin -M etcd -U' 
# Only one copy operation will succeed but depends on how the OS is installed 
# ssh $HOST_USER@$HOST1 'sudo cp -f /opt/rke2/share/rke2/rke2-cis-sysctl.conf /etc/sysctl.d/60-rke2-cis.conf' 
# ssh $HOST_USER@$HOST1 'sudo cp -f /usr/local/share/rke2/rke2-cis-sysctl.conf /etc/sysctl.d/60-rke2-cis.conf' 
# ssh $HOST_USER@$HOST1 'sudo cp -f /usr/share/rke2/rke2-cis-sysctl.conf /etc/sysctl.d/60-rke2-cis.conf' 

# ssh $HOST_USER@$HOST1 'sudo systemctl restart systemd-sysctl' 

# Apply Calico Extra config - If Required
# echo 
# echo "Copy calico config file to first node."
# echo "======================================"
# echo
# scp rke2-calico-config.yaml $HOST_USER@$HOST1:/tmp && ssh $HOST_USER@$HOST1 sudo cp /tmp/rke2-calico-config.yaml /var/lib/rancher/rke2/server/manifests/rke2-calico-config.yaml; done

# Enable and Start Cluster on 1st Node
echo 
echo "Enable and start RKE2 on First Node."
echo "===================================="
echo

ssh $HOST_USER@$HOST1 sudo systemctl enable rke2-server.service
ssh $HOST_USER@$HOST1 sudo systemctl start rke2-server.service

# Retrieve kubeconfig file from first host
echo 
echo "Retrieve kubeconfig file."
echo "========================="
echo

scp $HOST_USER@$HOST1:/etc/rancher/rke2/rke2.yaml rke2.yaml

# Adjust host in URL to reflect Load Balancer Address
echo 
echo "Update kubeconfig file, with cluster url."
echo "========================================="
echo

sed s/127.0.0.1/$CLUSTERNAME/ <./rke2.yaml >~/.kube/config
chmod 600 ~/.kube/config

# The Cluster has now been created with the first node, we can join nodes 2 & 3
#
