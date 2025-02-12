#!/bin/bash

# Source OpenStack credentials
source admin-openrc.sh

# Variables (customize as needed)
NETWORK_NAME="Tdia_network"
SUBNET_NAME="Tdia_subnet"
SUBNET_CIDR="10.10.1.0/24"
ROUTER_NAME="Tdia_router"
FLAVOR_NAME="m1.tdia"
IMAGE_NAME="Ubuntu-18.04"
SECURITY_GROUP_NAME="Tdia_sg"
INSTANCE_NAME="Tdia_Instance"
KEYPAIR_NAME="Tdia_Key"
PUBLIC_NETWORK="public"

# Step 1: Create Network
openstack network create $NETWORK_NAME

# Step 2: Create Subnet
openstack subnet create --network $NETWORK_NAME \
  --subnet-range $SUBNET_CIDR $SUBNET_NAME

# Step 3: Create Router and attach to public network
openstack router create $ROUTER_NAME
openstack router set $ROUTER_NAME --external-gateway $PUBLIC_NETWORK
openstack router add subnet $ROUTER_NAME $SUBNET_NAME

# Step 4: Create Flavor
openstack flavor create --vcpus 1 --ram 1024 --disk 5 $FLAVOR_NAME

# Step 5: Create Keypair
openstack keypair create $KEYPAIR_NAME > ${KEYPAIR_NAME}.pem
chmod 600 ${KEYPAIR_NAME}.pem

# Step 6: Create Security Group
openstack security group create $SECURITY_GROUP_NAME --description "Demo security group"

# Step 7: Add Rules to Security Group
openstack security group rule create $SECURITY_GROUP_NAME --protocol icmp --ingress  # ICMP (ping)
openstack security group rule create $SECURITY_GROUP_NAME --protocol tcp --dst-port 22   --ingress  # SSH
openstack security group rule create $SECURITY_GROUP_NAME --protocol tcp --dst-port 80   --ingress  # HTTP
openstack security group rule create $SECURITY_GROUP_NAME --protocol tcp --dst-port 443  --ingress  # HTTPS

# Step 8: Boot the Instance
openstack server create --flavor $FLAVOR_NAME \
  --image $IMAGE_NAME \
  --key-name $KEYPAIR_NAME \
  --security-group $SECURITY_GROUP_NAME \
  --network $NETWORK_NAME $INSTANCE_NAME

# Output status
openstack server list
