###############################################################
# Automating Infrastructure - Chef for DevOps by Whizlabs.com #
###############################################################

## These are my notes and examples written during the Automating Infrastructure - Chef for DevOps video course by Whizlabs.com ##
## Author: Daniel Cruz ##

## Additional reading resources for in depth knowledge ##
# Chef Recipes - https://docs.chef.io/recipes/
# Chef Resources - https://docs.chef.io/resources/directory/

###################
# Chef Components #
###################

# Chef Workstation
# - where cookbooks are created to later be pushed to a Chef Server
# - where knife tool is used to push cookbooks and to bootstrap nodes
# - could be a laptop or a PC the DevOps member use to create cookbooks/recipes

# Chef Node
# - a server that is managed or will be managed by Chef Server
# - will have a Chef client installed (bootstrapped)
# - will comunicate back and forth with Chef Server after being bootstrapped
# - will pull cookbooks and recipes from the Chef Server

# Chef Server
# - where are the cookbooks are eventually stored
# - the server that will communicate with the nodes to make sure they comply with the desired state
# - monitors the states of the nodes in a server/client fashion
# - pushed cookbooks/recipes to the Chef Nodes

# Workflow #
# Chef Workstation > Chef Server > Chef Nodes #
# Create Cookbooks > Upload Cookbooks > Bootstrap & Apply Cookbook

##############
# Chef Setup #
##############
# Download and install Chef Workstation from chef.io
# Create an account at manage.chef.io
# Create an organization name in manage.chef.io
# Download a Chef Workstartion starter file (chef-starter.zip) from manage.chef.io into the Chef Workstation
# Install a Chef Workstartion starter file downloaded from manage.chef.io into the Chef Workstation (chef-starter.zip)
# On the Chef Workstation machine, use the knife command to bootstrap the Chef Node
# Log into the manage.chef.io account and check the node section to see the newly node boostrapped



##############################################
# Overview of Recipes and Recipes Attributes #
##############################################

############
# Data Bag #
############

# Data Bag are used to store global variables as JSON data
# They are accessed during search and are loaded by a cookbook.

# To load the content of a Data Bag into a recipe
 {
     "id": "my_bag",
     "repository" : "git://github.com/repo_name/my_data.git"
 }

 # To access Data Bag in the recipe
 bag = data_bag_item_('my_bag', 'my_data')

 # To access the Data Bag item's keys and values with a hash
 bag['repository'] #=>
 'git://github.com/repo_name/my_data.git'


###########
# Recipes #
###########

# To include one or more recipes in a recipe use the include_recipe method

 # Syntax to include a recipe
 include_recipe 'recipe'

# Syntax to include multiple recipes
include_recipe 'cookbook::setup'
include_recipe 'cookbook::install'
include_recipe 'cookbook::configure'


#############
# Resources #
#############

# Chef resource represents a piece of the operating system at its desired state. It is a statement of configuration policy that describes the desired state of a node to which one wants to take the current configuration to using resource providers.

# Resources grouped in recipes
# - determine the desired state for a configuration item.
# - declare the steps thata re required to bring that item into the desired state
# - declare the resources types such as, package, template, or services
# - list the aditional details (resource properties) as necessary
# - every resource has it's own set of actions

# A resource consist of a Ruby block of code with four components:
# - Type
# - Name
# - Properties
# - Actions
type 'name' do
    attribute 'value'
    action :type_of_action
end

# A resource to install a TAR package can looks something like this:
# - all the actions in a resource have a default value
# - non default behaviors of the actions and properties needs to be specified

package 'tar' do
    version '1.16.1'
    action :install # example of default value that can be omitted
end

package 'tar' do
    version '1.16.1'
end


####################
# Custom Resources #
####################

property_name RubyType, default: 'value'

action_name do # a mix of built-in Chef resources and Ruby
end

another_action_name  do # another mix of built-in Chef resources and Ruby
end


###############################
# A Demonstration of a Recipe #
###############################

# All the resources documentation can be found by searching CHEF RESOURCES and then click on the ALL INFRA RESOURCES link.
# Resource documentaton found at https://docs.chef.io/resources/

# The resources on this recipe will be FILE, DIRECTORY, SCRIPT, USER, and GROUP

# On the Chef Workstation machine's home directory will be a chef-repo directory after
# unzipping the chef-starter.zip file (check the setup section for more details)
cd chef-repo
ls
cd cookbooks
chef generate cookbooks my_cookbook

knife cookbook list

cd my_cookbook
ls
cd recipes
ls

cat << EOF > default.rb

# resource 1 : FILE
file '/root/ChefFile' do
    content 'some content that will be in the file to be created in /root/ChefFile'
end
EOF

cd /root/chef-repo/cookbooks
knife upload cookbook my_cookbook
knife cookbook list
# Log into the https://manage.chef.io account
# Go to Nodes and check the new uploaded cookbook
# Go to Edit Runlist
# Drag my_cookbook recipe from Available Recipes to the Current Run List box 
# Click the Save Run List button


# On the Chef Node
chef-client
cd /root
ls
cat ChefFile


# On the Chef Workstation
cd chef-repo
ls
cd cookbooks
cd my_cookbook
cd recipes
ls

cat << EOF >> default.rb

# resource 2 : DIRETORY
directory '/root/ChefDir' do
    mode '0777'
    owner 'root'
    group 'root'
    action :create
EOF

# On the Chef Node
chef-client
cd /root
ls -la ChefDir


# On the Chef Workstation
cd chef-repo
ls
cd cookbooks
cd my_cookbook
cd recipes

cat << EOF > my_recipe.rb

# resource 3 : SCRIPT
script 'myscript' do
    interpreter "bash"
    code <<-EOH
      mkdir -p /root/123/1234/12345
      echo "Hello World" >> CheFile
      EOH
end
EOF

cd /root/chef-repo/cookbooks
knife upload cookbook my_cookbook
knife cookbook list

# Log into the https://manage.chef.io account
# Go to Edit Runlist
# Drag my_cookbook recipe from Current Run List box to the Available Recipes box
# And drag my_cookbook::my_recipe from Available Recipes to the Current Run List box 
# Click the Save Run List button

# On the Chef Node
chef-client
cd /root
ls
ls -R 123/
cat /ChefFile

# On the Chef Workstation
cd chef-repo
ls
cd cookbooks
cd my_cookbook
cd recipes

cat << EOF > new_recipe.rb

# resource 4 : USER
user 'my_user' do
    comment "Hello"
    uid 1234
    home '/home/myuser'
    shell '/bin/bash'
    password 'redhat'
end

# resource 5 : GROUP
group 'my_group' do
    comment 'Hello'
    gid 6430
    group_name 'my_group'
    members 'my_user'
end
EOF

cd /root/chef-repo/cookbooks
knife upload cookbook my_cookbook
knife cookbook list

# Log into the https://manage.chef.io account
# Go to Edit Runlist
# Drag my_cookbook::my_recipe recipe from Current Run List box to the Available Recipes box
# And drag my_cookbook::new_recipe from Available Recipes to the Current Run List box 
# Click the Save Run List button

# On the Chef Node
chef-client
id my_user


##########################
# Components of Cookbook #
##########################

# - Recipes
# - Attributes
# - Files - tells how to distribute files, including a node, a platform, or by file version
# - Libraries
# - Custom Resources
# - Templates
# - Ohai Plugin
# - Meta Data

# Files
# stored in Chef Infra cookbooks under Cookbook_file resource
# files will be copied from COOKBOOK_NAME/files/ to a specified path located at the host that is running Chef client
# files from COOKBOOK_NAME/files/default may be used on any platform

# Library
# Used to include Ruby code in a cookbook, mostly to write helpers used in recipe and custom resources
# UserLibrary file is a Ruby file within a cookbook or libraries director
# it can be used to extend functionalities (custom buil-in classes)
# example of usages: connect to a database, fetch the secrets, talking to an LDAP provider

# Custom Resource
# server as an extension of Chef Infra client

# Templates
# Embeded Ruby ERB used to dynamically generate static files such as configuration files

# Metadata
# Used to describe the information used to deploy the cookbook


####################
# Cookbook Example #
####################

# On the Chef Workstation
cd chef-repo
cd cookbook

knife cookbook list


chef generate cookbook apache
cd apache
cd recipes
ls

cat << EOF > default.rb
# Reource 1: for installing apache httpd package
package 'httpd' do
    action :install
end

# Resource 2: Creating content for our webpage
file '/var/www/html/index.html' do
    content "<html><head></head><body><h1><b>This is my webpage created using Chef Automation Tool.</h1></body></html>"
end


# Resource 3: Start the httpd service
service 'httpd' do
    action [ :start, :enable ]
end
EOF

cd /root/chef-repo/cookbooks/
ls

knife upload cookbook apache
knife cookbook list

# Log into the https://manage.chef.io account
# Go to Edit Runlist
# Drag apache recipe from Available Recipes box to the Current Run List box
# Click the Save Run List button

# On the Chef Node
chef-client


###############################################################################
# Cookbook Example: Bootstrap an Ubuntu Machine and create a web server on it #
###############################################################################

# On the Ubuntu Machine (soon to be Chef Node client)
# Setup a static IP and make this machine reachable over the network
# Set a root password
# Setup SSH access and permit root login to this machine
# alternatively, setup SSH key access to this machine
# Copy the ip address

# On the Chef Workstation
knife bootstrap 192.168.0.144 --connection-user root --ssh-password redhat -N ubuntu

knife node list
# Go to https://manage.chef.io account
# Go to the Node section and check the node newly added node

# On the Chef Workstation
cd /root/chef-repo/cookbooks
ls

chef generate cookbook httpd
cd httpd
cd recipes

cat << EOF > default.rb
package 'apache2' do
    action :install
end

file '/var/www/html/index.html' do
    content "web server hosted on Ubuntu"
end
service 'apache2' do
    action [ :enable, :start ]
end
EOF

knife cookbook upload httpd
knife node list
# Go to https://manage.chef.io account
# Go to the Node section and check the node newly added node
# Drag httpd recipe from Available Recipes box to the Current Run List box
# Click Save Run List

# On the Ubuntu machine (Chef Node)
chef-client


####################################
cd /root/chef-repo/coobooks

knife cookbook list

chef generate cookbook apache
cd apache
ls

cd recipes


cat << EOF >> default.rb

# Resource 1: Installing apache httd package
package 'httpd' do
    action :install
end

# Resource 2: Creating content for our webpage
file '/var/www/html/index.html' do
    content "<html><head></head><body><h1><b>This is my webpage created using Chef Automation Tool.</h1></body></html>"

# Resource 3: Enable and start the Apache HTTPD service
service 'httpd' do
    action [ :enable, :start]
end
EOF

########### PENDING TO RESUME THIS SECTION ###########

#############
# Data Bags #
#############

# Data Bags are container for items that contains information that needs to be shared with nodes
# A data bag can contain multiple individual files known as data bag items
# data bag items belongs to a specific data bag
# the data is not bound to a single node, but it can be used by multiple nodes
# contain information about shared by more than one nodes
# store Global Variables in the form of JSON data
# data bags are indexed for searching and can be loaded by a cookbook or ccessed during a search
# data bags are index for seaching 
# to share passwords & license keys
# to share user & group list
# data bag is formatted in JSON
# stored in a data_bag directory
# can be created using knife or manually
# can contain multiple data bags as data bags items
# each data bag item is stored as JSON format
# a data bag item must reference a data bag where it belongs to
# in a data bag string values are quoted, integer values are not

# Data Bag structure
{
    "id": "ITEM_NAME",
    "key": "value"
    /* Supported comment style */
    // Supported style
}

{
    'id': 'my_app'
    ...(truncated)...
    'deploy_key': ssh_private_key
}

# Using knife to access search within data bag
knife search admin_data "(NOT id:admin_users)"

# Search within a data bag using a cookbook
search(:admin_data, 'NOT id:admin_users'

# Example of a data bag
{
    "id": "some_data_bag_item",
    "production" : {
        # Hash with all the data

}

# Example of using a data bag in a recipe
data_bag_item[node.chef_environment]['some_other_key']


# Data bags can also be accessed by Chef-Solo
# Can be used to load the data when that data bag are accesible from a directory structure that exist on the same machine as Chef-Solo
# the location of this directory is configurable using the data_bag_path option in the Slo.rb file
# The name of each of the sub-directories corresponds to a data bag and each JSON file within a sub-directory corresponds to a data bag item.

###################################################################
# Exercise: Create a Data Bag and create users in the client node #
###################################################################
knife -h | grep data
cd /root/chef-repo

mkdir -p data_bags/users_data
ls

knife data bag list

cat << EOF > data_bags/users_data/users_to_create.json
{
    "id": "user01",
    "uid": "1100",
    "home": "/home/user01/"
}

cd /root/chef-repo/cookbooks
chef generate cookbook user_creation

cat << EOF > user_creation/recipes/default.rb

# Using a data bag on this recipe
user_data = data_bag_item('users_data', 'users_to_create')

# Create an user with values defined in the data bag named user_data (located in the users_data directory, in the users_to_create.json file)
user user_data['id'] do
    uid user_data['uid']
    home user_data['home']
end
EOF

cd /root/chef-repo
knife data bag from file users_data danny.json
# Go to https://manage.chef.io
# Check Data Bags > Policy section

knife cookbook upload usercreation
# Go to https://manage.chef.io
# Check the cookbook uploaded under the Cookbooks section
# Go to the Nodes section
# Go to Edit Run List
# Drag the usercreation cookbook from the Available Recipes to the Current Run List box
# Click Save Run List

# On the Chef-Node
chef-client
id danny


######################################################################
# Overview of Organizations, Users, Groups, and Roles on Chef Server #
######################################################################

# Creating an Organization
chef-server-ctl -h | grep org
chef-server-ctl -h | grep org-

# Create an organization
chef-server-ctl org-create myorg 'MyOrg, Inc.'

chef-server-ctl org-list

# Add an existing user to the organization
chef-server-ctl  org-user-add myorg user01

# Creating and adding users to a group
chef-server-ctl -h | grep user-

chef-server-ctl user-list

# Create an user
chef-server-ctl user-create my_username my_first_name my_last_name email@example.com 'my_password_goes_here'

# Go to the https://manage.chef.io to add this user to the organization
# Log as with the newly created user and click the Starter Kit
# Download the Starter Kit and extract it into the new user's workstation

# On the new user's workstation
cd cookbooks
chef generate cookbook test_book


# Create an user using the knife tool
knife -h | grep user

knife opc user create my_username my_first_name my_last_name email@example.com 'my_password_goes_here'

# List the users created
chef-server-ctl user-list
chef-server-ctl list-server-admins

# Removing an user
chef-server-ctl remove-server-admin-permissions user01

# Delete a specific user
chef-server-ctl user-delete user01

# Delete an organization
chef-server-ctl org-delete myorg
chef-server-ctl org-list
# Go to the https://manage.chef.io and check the organization under the Administration tab



###############
# Chef on AWS #
###############


# Spin up an EC2 for Chef Server
# Download and install Chef Infra Server
wget ...
rmp -Uvh chef-server-core-14.0.65-1.el7.x86_64.rpm
chef-server-ctl user-create <username> <first_name< <last_name> <email> <'password'> --filename <username.pem> # Create an user & PEM file
chef-server-ctl org-create <organization_name> <'organization_long_name'> --association_user <username> --filename <organization_name.pem> # Create an organization and associate an user to it
chef-server-ctl install chef-manage # Install Chef Manage Web UI Add-on
chef-server-ctl reconfigure # Reconfigure Chef Server to integrate the Chef Manage Web UI Add-on
chef-manage-ctl reconfigure --accept-license # Reconfigure Chef Server to work with Chef Manage Web UI Add-on

# Spin up an EC2 for Chef Workstation
# Download and install Chef Workstartion
# Log into the Chef Manage web interface (which is the same IP used for Chef Infra Server) and download the Starter Kit file
wget ...
unzip chef-starter.zip
cd chef-repo
knife ssl fetch # Will authenticathe pub/private keys
cd cookbooks
chef generate cookbook httpd # Generate a new cookbook named httpd
cd httpd

cat << EOF >> recipes/default.rb

package 'httpd' do
    action :install
end

service 'httpd' do
    action [:start, :enable]
end

cookbook_file '/var/www/html/index.html' do
    source 'index.html'
    mode '0664'
end
EOF

mkdir files
cat << EOF >> files/index.html

<html>
<p>
<b>This is a deployed on AWS<b>
</p>
</html>
EOF

cd ..

knife upload cookbook httpd  # Upload the cookbook to the Chef Infra server


# Spin up an EC2 to act as Chef Client (Node)
# Setup an static IP and network reachability between the Chef Server, Chef Workstration, and the Chef Client (node)
# Copy the Chef Client's IP address
# Log back into the Chef Workstation to bootstrap the Chef client/node from the Chef Workstation

# On the Chef Workstation
# Execute the command to bootstrap the Chef client (this will install the Chef Infra Client on the client/node)
knife bootstrap <client_ip> -U <username> -P <password> --node-name <node_name_for_reference>
# Log into the Chef Manage web UI to see the client node that has been added under the Nodes section/tab

# On the Chef Workstation
knife supermarket search motd # Search for cookbooks in the Chef Supermarket
knife supermarket download dynamic_motd
ls
tar -xzvf dynamic_motd-0.1.5.tar.gz && rm -f dynamic_motd-0.1.5.tar.gz
knife upload cookbook dynamic_motd
# Go to Chef Manage web UI and under Policy, check the cookbook uploaded in the list (dynamic_motd)
# Click on the Nodes tab
# Select the cookbook dynamic_motd
# Click the gear icon in the top right of the row (node's setting option under Actions)
# Click Edit Run List
# Drag the dynamic_motd recipe from the Available Recipes section into the Current Run List section
# Click the Save Run List button
# Go back to the Chef client server/node and execute the chef-client command

# On the Chef Client/Node
chef-client


##########################
# AWS Services with Chef #
##########################

# Setup Chef Workstation to Work with Amazon AWS Resources
# On Chef Workstation
yum -y install epel-release
yum -y install awscli

aws configue # This will require a programatic AWS access key ID and Secret Acces Key from AWS IAM user account

chef gem install knife-ec2 # Install AWS EC2 module/resource for Chef
knife ec2 server create --help # Command for help references

####################################
# AWS EC2 & VPC Services with Chef #
####################################
# On Chef Workstation

# Spin a new EC2 instance named awsec2node01 (-r <role> | -I <AMI instance ID> | -f <format> | -S <SSH_Key> | --connection-user <username> | -Z <zone> | --region <AWS region> | --node-name <EC2 instance name>)
knife ec2 server create -r 'role[httpd]' -I ami-0015b9ef68c77328d -f t2.micro -S my_key --connection-user centos --region us-east-1 -Z us-east-1a --node-name awsec2node01

# Spin a new EC2 instance on a specific VCP with a Security ID
# Spin a new EC2 instance named awsec2node01 (-r <role> | -I <AMI instance ID> | -f <format> | -S <SSH_Key> | --connection-user <username> | -g <Security Group ID> | --subnet <Subnet ID> | -Z <zone> | --region <AWS region> | --node-name <EC2 instance name>)
knife ec2 server create -r 'role[httpd]' -I ami-0015b9ef68c77328d -f t2.micro -S my_key --connection-user centos --region us-east-1 -g sg-08c91251e9c3d2cc5 --subnet subnet-00b08dc4c867c0a92 -Z us-east-1a --node-name awsec2node01

# List the EC2 instances in AWS
knife ec2 server list

# List the VPCs in AWS
knife ec2 vpc list

# List Security Groups
knife ec2 securitygroup list
 

###################################
# AWS Elastic Beanstalk with Chef #
###################################
# On Chef Workstation

chef generate cookbook beanstalk
cd beanstalk
cat << EOF >> recipes/default.rb

execute 'createapp' do
    command 'aws elasticbeanstalk create-application --application-name webapp --description my_web_app'
end

execute 'createenv' do
    command "aws elasticbeanstalk create-environment --application-name webapp --environment-name webappenv --description webappdesc --solution-stack-name '64bit Amazon Linux 2 v3.2.0 running Python 3.8' --tier Name=WebServer,Type=Standard --cname SampleApp --option-setting Namespace=aws:autoscaling:launchconfiguration,OptionName=IamInstanceProfile,Value=aws-elasticbeanstalk-ec2-role"
end
EOF

cd ..
knife upload cookbook beanstalk

chef-client -zr recipe'[beanstalk::default]'


#####################
# AWS RDS with Chef #
#####################
# On Chef Workstation

chef generate cookbook aws_rds
cat << EOF >> aws_rds/recipes/default.rb

execute 'create RDS' do
    command 'aws rds create-instance \
              --db-instance-identifier mysql_instance_name_goes_here \
              --db-instance-class db.t3.micro \
              --engine mysql \
              --master-user my_sql_root_user_goes_here \
              --master-user-password my_sql_password \
              --allocated-storage 20 \
              --publicly-accesible'
end
EOF

knife cookbook upload aws_rds

chef-client -zr "recipe[aws_rds::default]"

mysql -h mysql_instance_name_goes_here.ashkdjasdiu.us-east-1.rds.amazonaws.com -u my_sql_root_user_goes_here -p
show databases;
create database my_new_db;


#####################
# AWS ECS with Chef #
#####################
# On Chef Workstation
knife ec2 server create -I ami-<AMI Code> -f t2.micro -S My_SSH_Key --connection-user ec2-user --region us-east-1 -g sg-<Security Group ID> --subnet subnet-<Subnet ID> --iam-profile ecsRoleforEc2 --associate-public-ip --node-name container_instance_1 
knife botstrap <ec2_ip_address> -U ec2-user -i che-key.pem --sudo -N container_instance_1

chef generate cookbook container_instance

cat << EOF >> container_instance/recipes/default.rb

execute 'disable repo' do
    command 'sudo amazon-linux-extras disable docker'
end

execute 'install ecs agent' do
    command 'sudo amazon-linux-extras install -y ecs; sudo systemctl enable --now ecs'
end
EOF

knife upload cookbook container_instance

# Go to Chef Manage > Nodes > Select the container_instance_1 node > Click the Gear icon under Actions > Edit Node Run List
# Drag the container_instance recipe from Available Recipes section to the Current Run List section.
# Click Save Run List
# Run the chef-client command on the ec2 instance
chmod 400 *.pem
ssh -i chef-key.pem ec2-user@<container_IP_address> -t 'sudo chef-client'
ssh -i chef-key.pem ec2-user@<container_IP_address> -t 'curl -s http://localhost:51678/v1/metadata | python -mjason.tool'

# On Chef Workstation
aws esc create-cluster --cluster-name default
# THIS LAB IS INCOMPLETE



