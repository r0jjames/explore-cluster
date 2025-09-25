#!/bin/bash

# --- CONFIG --
DEFAULT_NODES=2
MEMORY=2G
CPU=2
DISK=10G
UBUNTU_VERSION=22.04
INVENTORY_FILE=inventory.ini
SSH_KEY="$HOME/.ssh/id_ed25519.pub"

NODES=${1:-$DEFAULT_NODES}

# --- SET DRIVER FOR APPLE SILICON ---
#echo "⚙️ Setting Multipass driver to qemu (for M1/M2)..."
#multipass set local.driver=qemu

# --- CREATE CLUSTER ---
echo "🚀 Launching $NODES Multipass nodes..."

for ((i=1; i<=$NODES;i++)); do
	NAME="ansible-node-0$i"
	
	if multipass info $NAME > /dev/null 2>&1; then
		echo "✅ $NAME already exists, skipping creation."
	else
		multipass launch -n $NAME -c $CPU -m $MEMORY -d $DISK $UBUNTU_VERSION
	fi
done

# Give time for networking
sleep 10


# --- INJECT SSH KEY ---
echo "🔑 Injecting your SSH public key into nodes..."

for i in $(seq 1 $NODES); do
    NAME="ansible-node-0$i"

    multipass transfer "$SSH_KEY" $NAME:/home/ubuntu/authorized_keys_temp
    multipass exec $NAME -- bash -c "
        mkdir -p ~/.ssh
        grep -q \"$(cat $SSH_KEY)\" ~/.ssh/authorized_keys || cat ~/authorized_keys_temp >> ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/authorized_keys
        rm ~/authorized_keys_temp
    "
done

# --- GENERATE ANSIBLE INVENTORY ---
echo "📝 Generating Ansible inventory file: $INVENTORY_FILE"
echo "[node_cluster]" > $INVENTORY_FILE

for i in $(seq 1 $NODES); do
    IP=$(multipass info ansible-node-0$i | grep IPv4 | awk '{print $2}')
    echo "$IP ansible_user=ubuntu ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> $INVENTORY_FILE
done

echo "✅ Cluster setup complete!"
cat $INVENTORY_FILE

echo "👉 Test connectivity with:"
echo "ansible -i $INVENTORY_FILE node_cluster -m ping"


