## Concept
In OpenStack, users are created for authentication, while projects organize and isolate resources. Users are assigned roles within projects to define access levels. Networks are configured to enable communication between instances, which are deployed within a project. This structure ensures security, resource isolation, quota management, and scalability.

## Create a project and a user 
1. Create a Project (Tdia_project):
    $ openstack project create --domain default --description "Project Description" Tdia_project

2.Create a User (Tdia_user):
    $ openstack user create --domain default --password <password> --project Tdia_project Tdia_user

--> Make sure to replace <password> with the user's password.

4.Verify the User :
To check if the user was created correctly.

    $ openstack user show Tdia_user
    $ openstack project show

## Configure Network
When you're performing operations as Tdia_user in OpenStack, you need to source the Tdia_user-openrc.sh file to authenticate as Tdia_user and perform actions within Tdia_project. The admin-openrc.sh file grants you administrative privileges and access to all projects, which is suitable for managing the OpenStack environment overall, but it doesn't give you the context of Tdia_user or the specific project.

For users, networking permissions are typically controlled by roles, so ensure the user (Tdia_user) has appropriate access to the networking resources. 
ensure that the 'member' role  is assigned to Tdia_user using this command :
    $ openstack role assignment list --user Tdia_user --project Tdia_project

Assign the 'member' role **if needed**:
    $ openstack role add --project Tdia_project --user Tdia_user member


Then,
log in to Tdia_user in The Dashboard using your credentials :(Tdia_user:<pasword>)

Download Tdia_user-openrc.sh file (in Project/'API Access').
move it to /opt/stack/ :
    $ sudo mv Tdia_user-openrc.sh /opt/stack/
    $ sudo su - stack

Source file :
    $ source Tdia_user-openrc.sh

Tdia_user-openrc.sh:
    This file contains the authentication details specific to Tdia_user in Tdia_project.
    You should source this file when performing tasks that involve managing resources within Tdia_project, such as launching instances, creating networks, and working within the confines of the user’s permissions.

### Step 1: Create a Router to Enable External Connectivity:
If you want the network to have internet access or connect to external networks, you need a router.
    $ openstack router create Tdia_router

verify the router's creation :
    $ openstack router list
you should see your router's name and its corresponding ID, status and state.

### Step 2: Create a Network
You need to create a network. This is a basic layer 2 network used to connect virtual machines (VMs) and other resources.
    $ openstack network create Tdia_network

Verify the network's creation using this command :
    $ openstack network list

### Step 3: Create a Subnet for the Network
Once the network is created, you need to create a subnet for it. A subnet defines the range of IP addresses that will be used for resources in this network.

    $ openstack subnet create Tdia_subnet \
                --network Tdia_network \
                --subnet-range 10.10.1.0/24 \
                --gateway 10.10.1.1 \
                --dns-nameserver 8.8.8.8 \
                --project Tdia_project
To verify the subnet's creation use :    
    $ openstack subnet list

And u should see your subnet's details

### Step 4: Add the Subnet to the Router:
To allow communication between the subnet and external networks, you must interface the router with the subnet.

    $ openstack router add subnet Tdia_router Tdia_subnet

### Step 5: Connect the Router to an External Network
To provide external connectivity (e.g., access to the internet), you need to connect the router to an external network. In many OpenStack environments, this is typically the public network.

    $ openstack router set --external-gateway <public> Tdia_router

replace <public> with the name of the external network (if different in your environment). you can run this commadn to get the name of your external network :
    $ openstack network list --external

!! If you find any errors, check the challenges section to fix them. !!

### Step 7 : Creating a Security Group
In OpenStack, a security group is a set of rules that control the incoming and outgoing network traffic for instances.

    $ openstack security group create Tdia_sg --description "Security group for Tdia_project"

1.Add Rules to the Security Group:
  a. ALL ICMP (ping):  
    $ openstack security group rule create --protocol icmp Tdia_sg
  
  b. ALLOW SSH (port 22) :
    $ openstack security group rule create --protocol tcp --dst-port 22 Tdia_sg
  
  c.ALLOW HTTP & HTTPS (ports 80/443):
    $ openstack security group rule create --protocol tcp --dst-port 80 Tdia_sg

    $ openstack security group rule create --protocol tcp --dst-port 443 Tdia_sg

2.Verify the security group and rules:
you can verify that the security group Tdia_sg was created and has the correct rules:
    $ openstack security group show Tdia_sg

## Create an Instance
### Step 1: Download Ubuntu image :
We are going to download the **[bionic-server-cloudimg-amd64.img](https://cloud-images.ubuntu.com/bionic/current/)** made by Openstack, which has a size of 387 MB and a description: QCow2 UEFI/GPT Bootable disk image.

Move the image to /opt/stack :
    $ mv bionic-server-cloudimg-amd64.img /opt/stack
    $sudo su - stack

### Step 2 : Create Ubuntu Image :
    $ openstack image create Ubuntu-18.04 \
            --file bionic-server-cloudimg-amd64.img \
            --disk-format qcow2 \
            --container-format bare \
            --min-disk 5 \
            --min-ram 1024 \
            --protected
Warning :
    You have to check first if openstack services can access those resources by running those commands:
        1.1 $ source admin-openrc.sh
        1.2 $ openstack hypervisor stats show
    Make sure that openstack services have suffisant resources like (more than 1024 gb of free_ram_mb and more than 5Gb disk --min-disk as mentionned in --min-ram and --mn-idisk) !!Check challenges for more info!!

Verify the image creation:
    $ openstack image list
You should see the new image (Ubuntu-18.04) in the output.


### Step 3: Creating a New Flavor in OpenStack
Creating a flavor in OpenStack allows you to define the specifications (vCPUs, RAM, disk, etc.) for virtual machines (VMs) that users can launch (It acts as a blueprint that limits the resources a user can allocate when creating an instance.)

1.Source the OpenStack admin RC file
Because flavors are controlled only by The admin.
    $source admin-openrc.sh

2.Create flavor :
    $ openstack flavor create <flavor_name> \
  --vcpus <number_of_vcpus> \
  --ram <amount_of_ram_in_MB> \
  --disk <disk_size_in_GB>

    • <flavor_name>: Provide a unique name for the flavor (e.g., m1.tdia).
    • <number_of_vcpus>: Enter the number of virtual CPUs for this flavor (e.g., 1).
    • <amount_of_ram_in_MB>: Specify the amount of RAM in megabytes (e.g., 1024 for 1 GB).
    • <disk_size_in_GB>: Enter the size of the root disk in gigabytes (e.g., 5).

3.Verify the Flavor:
    $ openstack flavor list

To view details about a specific flavor:
    $ openstack flavor show m1.tdia


### Step 4: Creating a key pairs
Make sure that you are interacting with OpenStack services as Tdia_user within Tdia_project using the command:
    $ source Tdia_user-openrc.sh
then :
    $ openstack keypair create --private-key tdia_private_key.pem Tdia_Key

Explain  :
    tdia_private_key.pem : Path and filename where the private key will be saved locally.
    Tdia_Key : The name for the key pair in OpenStack.

This command will:
    Save the private key to tdia_private_key.pem locally.
    Register the public key in OpenStack with the name Tdia_Key.

Verify the Key Pair:
    $ openstack keypair list 

You should see Tdia_Key in the output.

### Step 5: Create the instance
Now we need to put everything we creating before in one composant that is our Instance :
    $ openstack server create \
        --image Ubuntu-18.04 \
        --flavor m1.tdia \
        --network Tdia_network \
        --key-name Tdia_Key \
        Tdia_Instance





Verify the Instance: 
    $ openstack server list
If the instance is created successfully, it will show up in the list with the status=ACTIVE (if status=ERROR check challenges file to  fix issue).

## Access the Instance
If the instance is successfully created and the security group allows SSH, you can connect to it using the private key.

Before accessing an instance via SSH, you need to assign a floating IP address to it, especially if you're accessing it from outside the OpenStack private network. Here's how you can do it:

### Step 1: Check Available Floating IPs
    $ openstack floating ip list
If no floating IPs are available, you'll need to allocate one.

### Step 2: Allocate a Floating IP
    $ openstack floating ip create <external_network>

Replace <external_network> with the name or ID of the external network (Use command 'openstack network list --external' to get its name or ID).

This command will output a new floating IP address. **Note it down because it is your <floating_ip>**.

### Step 3: Assign the Floating IP to the Instance
Associate the floating IP with the instance's port:
    $ openstack server add floating ip Tdia_Instance <floating_ip>

### Step 4: Verify the Floating IP
    $ openstack server list
The floating IP should appear under the Networks column for your instance.


### Step 5: Access the Instance via SSH

    $ ssh -i <path_to_private_key> ubuntu@<instance_ip>

replace :
    <path_to_private_key> with the location of your private key (e.g., tdia_private_key.pem).
    <instance_ip>  with the floating or fixed IP of your instance.


