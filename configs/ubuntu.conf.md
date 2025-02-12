# Intuduction :
    The first step is to install and configure VirtualBox, which is a type 2 hypervisor that allows multiple virtual operating systems (guests) to run on a single host machine.

# The tools that will be used throughout this lab are as follows:
    • Oracle VM VirtualBox version 7.0.2.
    • An ISO file for installing Ubuntu Desktop 22.04.3.

# Set-up your ubuntu VM machine :
Create a new Vm Machine:
    • Name: openstack
    • RAM: 5 GB
    • CPU: 3
    • Storage: 80 GB
    • OS type to be installed: Linux
    • OS version to be installed: Ubuntu-22.04.5

update and upgrade the distro:
    $sudo apt update && sudo apt upgrade -y && sudo apt  
       dist-upgrade
Install requirementss:
    $sudo apt-get insatll bridge-utils -y && sudo apt    
       install net-tools -y
    $sudo apt-get install nano 

    
# Configure Network (Multi Adapters [1:Nat mode, 2:host-only mode]:
    1.Access the Network Manager section in VirtualBox (using Shortcut Ctr+H).
    2.Create a new Network interface named"Adapter #1" and configure it based on your requirements :
        -Adapter:
                Configure adapter manually {"IPv4": 192.168.56.1, "IPv4 Network Mask": 255.255.255.0
        -DHCP server: disable.

    3. Navigate to Settings -> Network :
        3.1.Enable First netwrok adapter and set it to “Bridge adapter” Mode.(with : Promiscuous Mode : allow ALL) , this one is used by our Vm to access internet.
        3.2.Enable Second netwrok adapter and set it to o 'Host-only Adapter' mode (with: name : "Adapter #1"; Promiscuous Mode : allow ALL), which will be used by OpenStack’s services to communicate with each other without any interaction with the external network.

    4. Access Your Vm machine and then check the network configurations , using the command “ifconfig”:
        , there are two main network adapters: enp0s3, and enp0s8 (configured with the IP range 192.168.56.X. Both adapters are active and assigned unique subnets.