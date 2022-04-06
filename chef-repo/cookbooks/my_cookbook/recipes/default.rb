#
# Cookbook:: my_cookbook
# Recipe:: default
#
# Copyright:: 2022, The Authors, All Rights Reserved.
include_recipe 'chef-client'
include_recipe 'apt'
include_recipe 'ntp'

file '/tmp/local_mode.txt' do
  content 'created by chef client local mode'
  action :create
end

template '/tmp/greeting.txt' do
  variables greeting: 'Hello!'
  action :create
end

file "/tmp/greeting.txt" do
  content node['my_cookbook']['greeting']
end


# How data bag and data bag items works (the structure)

# ./chef-repo/data_bags/hooks/request_bin.json
# {
#     "id": "request_bin",
#     "url": "http://<YOUR_REQUEST_BIN_ID>"
# }

# Data Bag name: hooks
# Data Bag item: request_bin
# Data Bag item defined inside the file: request_bin.json
# What will happen, the recipe retrieves the data bag item using the data_bag_item method, taking the data bag name as the first parameter and the item name as the second parameter.
# Then, we created an http_request resource by passing it the url attribute of the data bag item

# Calling the data bag item named request_bin inside a data bag named hooks
hook = data_bag_item('hooks', 'request_bin')
http_request 'callback' do
  url hook['url']
end


# Order of precedence for attributes files before Chef executes recipes
# 1 - default - lower
# 2 - force_default
# 3 - normal (set)
# 4 - override
# 5 - force_override
# 6 - automatic - higher

# Overriding an attribute inside a recipe
node.override['my_cookbook']['version'] = '1.5'
execute 'echo the cookbook version' do
  command "echo #{node['my_cookbook']['version']}"
end

# Use the attribute inside a recipe
message = node['my_cookbook']['message']
Chef::Log.info("** Saying what I was told to say: #{message}")

