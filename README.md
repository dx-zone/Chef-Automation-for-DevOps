# Chef Infrastructure and Cloud Automation - Quick Reference



This is my quick reference of commands, configuations and procedures to setup a local environment on Mac OS X during my learning process for infrastructure and cloud automation with Chef, Knife, Cookbooks, Vagrant, and other automation modules with Ruby. The references and commands documented are the results of my learning experience and the findings following along the Chef documentation and other books.



**Books and resources I'm learning from:**

[Chef Cookbook 3ed](https://subscription.packtpub.com/book/networking-and-servers/9781786465351/2/ch02lvl1sec31/integration-testing-your-chef-cookbooks-with-test-kitchen), by Matthias Marschall

[Learn Ruby The Hard Way, 3rd Edition](https://learnrubythehardway.org/book/), by Zed A. Shaw

[Automating Infrastructure - Chef for DevOps](https://www.whizlabs.com/learn/course/chef-for-devops/382/video), by Whizlabs.com




**Chef documentation**

* [Install Chef Workstation (formerly known as ChefDK)](https://docs.chef.io/workstation/install_workstation/)
* [Setup Chef Workstation](https://docs.chef.io/workstation/getting_started/)
* [About Attributes](https://docs.chef.io/attributes/)
* [All Infra Resources](https://docs.chef.io/resources/)
* [Ohai & Automatic Attributes](https://docs.chef.io/ohai/)



### Getting Started: Installing and Setting The Environment



Install Ruby on Mac OS X and update RubyGems (Ruby package manager)

```bash
brew install ruby

gem update --system
```



Install Chef Workstation on Mac OS X

```bash
brew install --cask chef-workstation
```



In case we need to uninstall and start a clean Chef Workstation installation, execute the uninstall script

```bash
uninstall_chef_workstation
rm -fr ~/.chef*
rm -fr ~/Library/Application\ Support/Chef\ Workstation\ App/
rm -fr /etc/chef
gem uninstall chef chef-config chef-telemetry chef-utils chef-vault chef-zero
```



Configure Ruby Environmnet for Chef

```bash
# BASH
echo 'eval "$(chef shell-init bash)"' >> ~/.bashrc
chef shell-init bash

#ZSH
echo 'eval "$(chef shell-init zsh)"' >> ~/.zshrc
chef shell-init zsh
```



Create a Chef account at Chef Manage (Hosted Chef https://manage.chef.com). Download and extract the Chef Starter Kit which contains your credentials, keys (<USER>.pem) and initial Chef repo diretory (chef-repo).

```bash
# To download the Starter Kit go to:
# Administration > Select your Organization ID > Starter Kit > Download Starter Kit
# Extract the StarterKit.zip and go into the chef-repo directory to get started
# If you are using 
```



Alternatively to a Hosted Chef (https://managed.chef.io), if you are using Chef Server hosted in your private cloud/premises, then setup your Chef repo & credentials by following the instructions from https://docs.chef.io/workstation/getting_started/

```bash
# Download and extract the StarterKit.zip from your 
chef generate repo chef-repo
```



**Starting to Work at Chef Working Directory (the chef-repo directory)**

```bash
cd chef-repo/
```



Create a new cookbook named *my_cookbook* with the **chef** tool

```bash
chef generate cookbook cookbooks/my_cookbook
```



Create a new cookbook named *my_cookbook* with the **knife** tool

```bash
knife generate cookbook my_cookbook
```



Upload a cookbook to Chef Server

```bash
knife cookbook upload my_cookbook
```



Download a cookbook previously uploaded to a Chef Server or to a Hosted Server

```bash
knife cookbook download my_cookbook
```



Delete a cookbook from Chef Server

```bash
knife cookbook delete <cookbook name>
```



Add a cookbook to your node's runlist

```bash
knife node run_list add server 'recipe[my_cookbook]'
```



Remove a server from a node's runlist

```bash
knife node run_list delete server 'recipe[my_cookbook]'
```



Run the Chef client on your node to associate the host, add it as a node, and bootstrap it to the Chef Server or Hosted Chef

```bash
sudo chef-client
```



Show the list of the nodes that has been bootstrapped to Chef Server or to Hosted Chef

(hosts with the `chef-client` installed and bootstrapped)

```bash
knife node show server
```




Show the list of the chef-clients association of the hosts that has been bootstrapped to Chef Server or to Hosted Chef with the `chef-client` agent.

```bash
knife client list
```



Test a cookbook with Test Kitchen

```yaml
cat << EOF >> .kitchen.yml
---
driver:
  name: vagrant

provisioner:
  name: chef_zero

#verifier:
#  name: inspec

platforms:
  - name: ubuntu-18.04

suites:
  - name: default
    run_list:
      - recipe[my_cookbook::default]
    attributes:
EOF
```

```bash
kitchen verify
kitchen test
```



Search the Marketplace for Cookbooks

```bash
knife supermarket search iptables

knife supermarket search ntp

knife supermarket search mysql
```



Shows details about the Cookbook searched in the Supermarket

```bash
knife supermarket show iptables

knife supermarket show ntp

knife supermarket show mysql
```



Download a Cookbook from the Marketplace

```bash
knife supermarket download iptables
tar zxvf iptables.tar.gz
```



Upload a cookbook on your Chef server

```bash
knife cookbook upload iptables --include-dependencies
```



Find the current version of a cookbook

```bash
knife cookbook show iptables
```



Inspect a cookbook syntax with Cookstyle tool (syntax and style-cheking tool for Ruby and cookbooks)

```bash
cookstyle cookbooks/my_cookbook

cookstyle -C true cookbooks/my_cookbook
```



Downloads all the dependencies you defined recursively with Berkshelf and upload the cookbook

```bash
cat << EOF >>> cookbooks/my_cookbook/metadata.rb
depends 'chef-client'
depends 'apt'
depends 'ntp'
EOF

cat << EOF >>> cookbooks/my_cookbook/recipes/default.rb
include_recipe 'chef-client'
include_recipe 'apt'
include_recipe 'ntp'
EOF

cd cookbooks/my_cookbook

chef generate cookbook -b ./

berks install

berks upload
```



Integrate Berkshelf with Vagrant to install and uploads all the required cookbooks on your Chef server whenever you execute **vagrant up** or **vagrant provision**

```ruby
cat << EOF >> Vagrantfile
# -*- mode: ruby -*-
# vi: set ft=ruby :

box_image = 'ubuntu/bionic64'
your_org = 'https://api.chef.io/organizations/mydatacenter'
your_user_key = '.chef/dx-zone.pem'
your_user = 'dx-zone'
node_name = 'server'

Vagrant.configure("2") do |config|
  config.vm.box = box_image
  config.vm.box_url = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-16.04_chef-provisionerless.box'
  config.omnibus.chef_version = :latest
  config.berkshelf.enabled = true

  config.vm.provision :chef_client do |chef|
    chef.provisioning_path = '/etc/chef'
    chef.chef_server_url = your_org
    chef.validation_key_path = your_user_key
    chef.validation_client_name = your_user
    chef.node_name = node_name
  end
end
EOF

cat << EOF >> Berksfile
source 'https://supermarket.chef.io'
cookbook 'my_cookbook', path: 'cookbooks/my_cookbook'
EOF

vagrant up

vagrant reconfigure
```



List the **knife** plugins that are sipped as Ruby gems using the **chef** command-line tool

```bash
chef gem search -r knife-
```



Install EC2 plugin to manage servers in the Amazon AWS Cloud

```bash
chef gem install knife-ec2
```



List all the available instance types in AWS using the `knife ec2` plugin

```bash
knife ec2 flavor list --aws-access-key-id <YOUR_AWS_KEY_ID> --aws-secret-access-key <YOUR_AWS_ACCESS_KEY>
```



List the nodes (chef-clients) registered on a Chef Server

```bash
knife node list
```



Delete a node (chef client) registered on a Chef Server

```bash
knife node delete my_node
```



Delete the client object of a node (chef-client) registered on a Chef Server

```bash
knife client delete my_node
```



Delete both the client and the node from Chef Hosted/Server (I.E. node named *server* in this case)

```bash
knife node delete server -y && knife client delete server -y
```



Install a command-line tool that allows you to do both deletions, delete the node and the client object at once.

```bash
chef gem install knife-playground
```



Delete both, the node and the client object simultaneously with the `knife-playground` tool

```bash
knife pg clientnode delete my_node
```



Run a cookbook and deploy a recipe with local mode (without a Chef Server or hosted Chef) and validate that the Chf client run creates the desired temporary file on you local workstation

```bash
chef generate cookbook cookbooks/my_local_cookbook

cat << EOF >>> cookbooks/my_local_cookbook/recipes/default.rb
file '/tmp/local_mode.txt' do
    content 'creaed by chef client local mode'
    action :create
end
EOF

chef-client --local-mode -o my_local_cookbook

cat /tmp/local_mode.txt
```



Run a cookbook locally on a chef client server/node without pulling the cookbook from the Chef Server (assuming the cookbook has been created locally in the chef client/node server).

```bash
chef-client --local-mode -o my_local_cookbook
```



Using `knife` in local mode just like running a cookbook with `chef-client` in local mode.

```bash
knife node run_list add -z laptop 'recipe[my_cookbook]'
```



Group nodes with similar configuration with **roles**.

Create a **role** and upload the **role** to Chef Server

```bash
cat << EOF >> my_cookbook/roles/web_servers.rb
name 'web_servers'
description 'This role contains nodes, which act as web servers'
run_list 'recipe[ntp]'
default_attributes 'ntp' => {
    'ntpdate' => {
        'disable' => true
    }
}

knife role from file web_servers.rb
```



Upload a **role** to the Chef Server

```bash
knife role from file web_servers.rb
```



Assign a **role** to a node called *server*

```bash
knife node run_list add server 'role[web_servers]'
```



Remove a node from the **role** called *server*

```bash
knife node run_list add server 'role[web_servers]'
```



Creating a separated Chef environments for development named *dev* (but it could be for development, testing, and/or production) and list the environment variables

```bash
export EDITOR=$(which vi) # for vim

knife environment create dev

knife environment list
```



List the environment of the nodes

```bash
knife node list

knife node list -E dev
```



Change the environment of the node named *server* to *dev* using `knife`

```bash
knife node environment set server dev
```



Use specific cookbook version and override certain attributes for the environment

```bash
knife environment edit dev

{
  "name": "dev",
  "description": "",
  "cookbook_versions": {
    "ntp": "1.6.8"
  },
  "json_class": "Chef::Environment",
  "chef_type": "environment",
  "default_attributes": {
  },
  "override_attributes": {
    "ntp": {
      "servers": ["0.europe.pool.ntp.org", "1.europe.pool.ntp.org", "2.europe.pool.ntp.org", "3.europe.pool.ntp.org"]
    }
  }
}
```



Alternatively, you can create a new environment with with a new Ruby file in he *environments* diretory inside your Chef repository.

```bash
cat << EOF >> ./chef-repo/environments/dev.rb
{
  "name": "dev",
  "description": "",
  "cookbook_versions": {
    "ntp": "1.6.8"
  },
  "json_class": "Chef::Environment",
  "chef_type": "environment",
  "default_attributes": {

  },
  "override_attributes": {
    "ntp": {
      "servers": [
        "0.europe.pool.ntp.org",
        "1.europe.pool.ntp.org",
        "2.europe.pool.ntp.org",
        "3.europe.pool.ntp.org"
      ]
    }
  }
}
EOF
```



Create the environment on the Chef server from the newly created file using knife

```bash
knife environment from file dev.rb
```



Sync your local changes to your Chef server for both, knife and Berkshelf simultaneously

```bash
knife exec -E 'nodes.transform("chef_environment:_default") { |n| n.chef_environment("dev") }'
```



Search for nodes in a specific environment (*dev* in this example)

```bash
knife search node 'chef_environment:dev'
```



Freezing a cookbook version to avoid someone to overwrite the same version with a broken code

```bash
knife cookbook upload ntp --freeze
```



Force overwrite a cookbook that has been already frozen

```bash
knife cookbook upload ntp --freeze --force

berks upload --force
```



Start the Chef client in daemon mode so that it runs automatically every 30 minutes and validate it is running

```bash
sudo chef-client -i 1800

ps auxw | grep chef-client
```



You can use the `chef-client` cookbook to install the Chef client as a service

```
knife supermarket download chef-client

tar zxvf chef-client.tar.gz

mv chef-client ./chef-repo/cookbooks && rm chef-client.tar.gz

knife cookbook upload chef-client

berks upload
```



Using Cronjob to run the Chef client as a daemon every 15 minutes

```bash
cat << EOF >> /etc/cron.d/chef_client
PATH=/usr/local/bin:/usr/bin:/bin
# m h dom mon dow user command
*/15 * * * * root chef-client -l warn | grep -v 'retrying [1234]/5 in'
EOF
```



Write unit tests to test fails a recipe and inspect it with Chef Spec

```bash
cat << EOF >> cookbooks/my_cookbook/spec/default_spec.rb
require 'chefspec'
describe 'my_cookbook::default' do
  let(:chef_run) {
    ChefSpec::ServerRunner.new(
      platform:'ubuntu', version:'16.04'
    ).converge(described_recipe)
  }
  
  it 'creates a greetings file, containing the platform name' do
    expect(chef_run).to render_file('/tmp/greeting.txt').with_content('Hello! ubuntu!')
  end
end
EOF

chef exec rspec   cookbooks/my_cookbook/spec/default_spec.rb

cat << EOF >> cookbooks/my_cookbook/recipes/default.rb
template '/tmp/greeting.txt' do
  variables greeting: 'Hello!'
  action :create
end
EOF

mkdir cookbooks/my_cookbook/templates

cat << EOF >> cookbooks/my_cookbook/templates/greeting.txt.erb
<%= @greeting %> <%= node['platform'] %>!
EOF

chef exec rspec cookbooks/my_cookbook/spec/default_spec.rb


```



Create a profile for compliance auditing and testing with Chef InSpec

```bash
# Create a new profile for your InSpec tests
inspec init profile my_profile

# Create a test ensuring that there is only one account called root with UID 0 in your /etc/passwd file
cat << EOF >> my_profile/controls/passwd.rb
describe passwd.uids(0) do
  its('users') { should cmp 'root' }
  its('entries.length') { should eq 1 }
end
EOF

# Run the test
inspec exec my_profile/controls/passwd.rb
```



Integration-testing Chef cookbooks and creating default attributes

```bash
# Edit your cookbook's default recipe
cat << EOF >> cookbooks/my_cookbook/recipes/default.rb
file "/tmp/greeting.txt" do
  content node['my_cookbook']['greeting'] # Resolve to 'content "Ohai, Chefs!"' as defined in the attributes/default.rb
end
EOF

# Edit your cookbook's default attributes
mkdir -p cookbooks/my_cookbook/attributes

cat << EOF >> cookbooks/my_cookbook/attributes/default.rb
default['my_cookbook']['greeting'] = "Ohai, Chefs!"
EOF

# Change to your cookbook directory
cd cookbooks/my_cookbook

# Edit the default Test Kitchen configuration file to only test against Ubuntu 18.04
cat << EOF >> ./chef-repo/.kitchen.yml
platforms:
  - name: ubuntu-18.04
#  - name: ubuntu-20.04
#  - name: centos-8

EOF

# Create your test, defining what you expect your cookbook to do:
mkdir test/recipes/

cat << EOF >> test/recipes/default_test.rb
describe file('/tmp/greeting.txt') do
  its('content') { should match 'Ohai, Chefs!' }
end
EOF

# Run Test Kitchen
kitchen test

# Alternative, Test Kitchen against a particular platform/version
kitchen test default-ubuntu-20.04
kitchen test 20

# List the status of the various VMs managed by Test Kitchen
kitchen list
```



 Pre-Flight checks before executing a cookbook to find which nodes will be affected and how

```bash
# PENDING TO COMPLETE THIS PART: Showing affected nodes before uploading cookbooks

chef gem install knife-preflight

knife preflight ntp

knife search node recipes:ntp -a name

knife search node roles:ntp -a name
```



Try parts of a cookbook interactively with `chef-shell`

```bash
chef-shell
```

