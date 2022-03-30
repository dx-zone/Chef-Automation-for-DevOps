#
# Cookbook:: my_cookbook
# Recipe:: default
#
# Copyright:: 2022, The Authors, All Rights Reserved.
#include_recipe 'chef-client'
#include_recipe 'apt'
#include_recipe 'ntp'

file '/tmp/local_mode.txt' do
    content 'creaed by chef client local mode'
    action :create
end
