# Chef Cookbook commands

# Create a Cookbook file structure named 'apache2'
chef generate cookbook apache2

# Upload a cookbook to Chef Infra server
knife cookbook upload apache2

# Bootstrap a node
knife bootstrap <IP-ADDRESS> --ssh-user root --ssh-password <YOUR-PASSWORD_GOES_HERE> --node-name chef-node1 --run-list 'recipe[apache2]'

# Create a Cookbook to publish it in the Chef Supermarket
chef generate cookbook jenkins-cicd -C <CHEF-SUPERMARKET-USERNAME>

knife supermarket share cookbook jenkins-cicd --user <CHEF-SUPERMARKET-USERNAME> --key <KEY.PEM-DOWNLOADED-FROM-THE-SUPERMARKET>

knife show

knife unshare

# chef-run - tool to run agentless ad-hoc commands with chef-run
# install NTP package on a remote server
chef-run <REMOTE-SERVER-IP> package ntp action=install --password <REMOTE-SERVER-PASSWORD>

# run a cookbook using ad-hoc commands
# this will execute the default recipe stored in the apache2 directory/cookbook
chef-run <REMOTE-SERVER-IP> apache2::default --password <REMOTE-SERVER-PASSWORD>

# Execute cookbook on multiple nodes using ranges
# in this case, web02, and web03
chef-run web0[2:3] nginx --password <REMOTE-SERVER-PASSWORD>

