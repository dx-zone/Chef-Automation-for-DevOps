#
# Cookbook:: my_local_cookbook
# Recipe:: default
#
# Copyright:: 2022, The Authors, All Rights Reserved.
file '/tmp/local_mode.txt' do
    content 'creaed by chef client local mode'
    action :create
end
