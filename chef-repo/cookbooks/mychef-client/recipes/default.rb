#
# Cookbook:: mychef-client
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

node.default["chef_client"]["interval"] = "600"
node.default["chef_client"]["splay"] = "20"

include_recipe 'chef-client::default'
