#
# Cookbook:: myhaproxy
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
# Updated the documentation
node.deafult['haproxy']['members'] = [
 {
   "hostname" => 'web1',
   "ipaddress" => '192.168.10.43',
   "port" => 80,
   "ssl_port" => 80
 }]

include_recipe "haproxy::manual"
