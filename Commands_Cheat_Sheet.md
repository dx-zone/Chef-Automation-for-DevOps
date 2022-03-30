Show clients bootstrapped to Chef Hosted/Server

(Servers with the Chef-Client installed and bootstrapped)

```bash
knife client list
```


Dele both the client and the node from Chef Hosted/Server

```bash
knife node delete server -y && knife client delete server -y
```



Create a new cookbook named *my_cookbook* with the **chef** tool

```bash
chef generate cookbook cookbooks/my_cookbook
```



Create a new cookbook named *my_cookbook* with the **knife** tool

```
knife generate cookbook cookbooks/my_cookbook
```

Upload a cookbok to Chef Server

```bash
knife cookbook upload my_cookbook
```



Add a cookbook to your node's runlist

```bash
knife node run_list add server 'recipe[my_cookbook]'
```



Run the Chef client on your node

```bash
sudo chef-client
```



Test a cookbook with Test Kitchen

```yaml
cat << EOF > .kitchen.yml
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



Inspect a cookbook syntax with Cookstyle tool

```bash
cookstyle cookbooks/my_cookbook
```



Downloads all the dependencies you defined recursively with Berkshelf and upload the cookbook

```bash
cat << EOF >> cookbooks/my_cookbook/metadata.rb
depends 'chef-client'
depends 'apt'
depends 'ntp'
EOF

cat << EOF >> cookbooks/my_cookbook/recipes/default.rb
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
cat << EOF > Vagrantfile
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

cat << EOF > Berksfile
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

cat << EOF >> cookbooks/my_local_cookbook/recipes/default.rb
file '/tmp/local_mode.txt' do
    content 'creaed by chef client local mode'
    action :create
end
EOF

chef-client --local-mode -o my_local_cookbook

cat /tmp/local_mode.txt
```



s