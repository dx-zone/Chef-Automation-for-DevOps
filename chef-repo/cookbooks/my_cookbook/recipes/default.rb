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
