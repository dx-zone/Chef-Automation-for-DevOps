# See http://docs.chef.io/workstation/config_rb/ for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "dx-zone"
client_key               "#{current_dir}/dx-zone.pem"
chef_server_url          "https://api.chef.io/organizations/mydatacenter"
cookbook_path            ["#{current_dir}/../cookbooks"]
cookbook_copyright "Mydatacenter.io"
cookbook_license "apachev2"
cookbook_email "dx.zone@gmail.com"
