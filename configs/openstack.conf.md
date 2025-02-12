-->> Once Ubuntu is installed and the network is configured, we will proceed to the next step: installing OpenStack.

# Install Devstack
    DevStack is an open-source toolset used to quickly deploy an OpenStack environment for development and testing purposes. It simplifies the installation process by providing scripts that set up a minimal, functional OpenStack environment on a single machine or small-scale cluster.


Create a non root user :

    $sudo useradd -s /bin/bash -d /opt/stack -m stack
    $echo "stack ALL=(ALL) NOPASSWD:ALL" | sudo tee 
       /etc/sudoers.d/stack

Switch to the stack user:

    $ su - stack

Clone the official DevStack repository:

    $git clone https://opendev.org/openstack/devstack
    $cd devstack


# Configuring the `local.conf` File:
The local.conf file is a configuration file for DevStack. It allows the user to specify 
various configuration parameters such as  : which OpenStack services to enable, IP 
addresses, passwords, etc. It plays a crucial role in customizing the OpenStack 
installation via DevStack.

Copy local.conf file from /samples directory to Desctack directory :

    ~/devstack$ sudo cp samples/local.conf .

Retrieve the IP address of the second network interface, which was previously attached using Adapter #1.:

    ~/devstack$ ifconfig

The IP address should begin with 192.168.56.x, as specified in the Adapter #1 configuration.

Modify the file local.conf :

    ~/devstack$ sudo nano local.conf

=> Set passwords :
These passwords are required for administrative access, database, RabbitMQ, and 
OpenStack services. Replace “massin” with a secure and unique password in 
production environments.(make sure to remember the password).

# Define the admin password :
    ADMIN_PASSWORD= massin #(Set ur own password)
    DATABASE_PASSWORD=$ADMIN_PASSWORD
    RABBIT_PASSWORD=$ADMIN_PASSWORD
    SERVICE_PASSWORD=$ADMIN_PASSWORD

=> Set Host ip:

# Specify the IP address for your machine
    HOST_IP= 192.168.56.X (make sure to put your IP)


# Change the ownership of /opt/devstack
we change the ownership of the /opt/devstack directory and all of its contents to 
the user 'stack' and the group 'stack'. This is because when deploying OpenStack with 
DevStack, the installation directory requires specific permissions for the stack user to 
ensure the proper functioning of the OpenStack services.

    $ sudo chown -R stack:stack /opt/stack


# Run stack.sh
This is a crucial step because you need to ensure everything is set correctly before running the stack.sh script (e.g., the IP address is correct, and the Stack user has all the necessary permissions in the DevStack directory).
Then, we run the stack.sh script:

    ~/devstack$ ./stack.sh

This is going to take a while, so just Wait and Pray .

When the installation is complete and no errors occur, you should see the default usernames and passwords for the Admin and Demo users. By default, they are:

    -Admin: admin:$your_password
    -Demo: demo:$your_password
    
Here, $your_password refers to the password you specified earlier in the local.conf file."



You can access the dashboard by opening a web browser and going to the 
IP address of your machine (by default, this is often http://localhost/dashboard)

# OpenStack: Managing with Command Line tools:

To interact with OpenStack services using command-line tools, we'll first download the 'admin-openrc.sh' file from the OpenStack graphical interface.

1.Connect to dashboard using admin credentials:
    log-in using admin credentials (admin:$your_password)

2.Chose admin project.

3.Access “Api Access” Interface.

4.Install admin-openrc.sh file.

5.Move the file into stack home directory:

    $ mv admin-openrc.sh /opt/stack/
    $ sudo su - stack #(make sure to to switch to the stack user)

6.Source the file to set the environment variables using the following command:

        $ source admin-openrc.sh


6.Check if it works :
Run Command:
    $ openstack service list

this command provides information about the services that are available in the OpenStack environment and their corresponding API endpoints.

## Now you're ready to move on to the next section about creating an instance (/instances directory)
