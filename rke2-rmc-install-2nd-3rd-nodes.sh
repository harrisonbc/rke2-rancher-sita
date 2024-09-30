#!/usr/bin/env bash

# Set Up variables
set -a
source variables.env
set +a

# The Cluster has now been created with the first node, we can join nodes 2 & 3
#
# Install RKE2 on 2nd & 3rd Node to join cluster created on 1st node

echo 
echo "Install RKE2 on Second & Third Node."
echo "===================================="
echo

for i in $HOST23; do ssh $HOST_USER@$i sudo INSTALL_RKE2_VERSION=$RKE2_VERSION ~/suse/rancher/install.sh; done

# Perform CIS 1.23 Hardening Actions on 2nd & 3rd Node (Create etcd user & group, copy config file to correct location)
# echo 
# echo "Perform CIS Hardening steps on Second & Third Node."
# echo "==================================================="
# echo
# for i in $HOST23; do ssh $HOST_USER@$i 'sudo useradd -r -c "etcd user" -s /sbin/nologin -M etcd -U' ; done

# for i in $HOST23; do ssh $HOST_USER@$i 'sudo cp -f /opt/rke2/share/rke2/rke2-cis-sysctl.conf /etc/sysctl.d/60-rke2-cis.conf' ; done
# for i in $HOST23; do ssh $HOST_USER@$i 'sudo cp -f /usr/local/share/rke2/rke2-cis-sysctl.conf /etc/sysctl.d/60-rke2-cis.conf' ; done
# for i in $HOST23; do ssh $HOST_USER@$i 'sudo cp -f /usr/share/rke2/rke2-cis-sysctl.conf /etc/sysctl.d/60-rke2-cis.conf' ; done

# for i in $HOST23; do ssh $HOST_USER@$i 'sudo systemctl restart systemd-sysctl' ; done


# Enable and Start Cluster on 2nd & 3rd Nodes
echo 
echo "Enable and start RKE2 on Second and Third Node."
echo "==============================================="
echo

for i in $HOST23; do ssh $HOST_USER@$i sudo systemctl enable rke2-server.service; done
for i in $HOST23; do ssh $HOST_USER@$i sudo systemctl start rke2-server.service; done

# The Cluster should now be created up and running.
echo 
echo "RKE2 Cluster up and running."
echo "============================"
echo

kubectl get nodes
