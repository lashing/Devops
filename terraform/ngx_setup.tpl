#!/bin/bash 
suod yum install -y wget
sudo rm -f /etc/chef/client.pem
curl -L https://www.opscode.com/chef/install.sh | sudo bash -s -- -v 12.20 
sudo mkdir -p /var/log/chef 
sudo mkdir -p /var/backups/chef 
sudo mkdir -p /var/run/chef 
sudo mkdir -p /var/cache/chef 
sudo mkdir -p /var/lib/chef 
sudo mkdir /etc/chef 
sudo wget https://s3-us-west-2.amazonaws.com/chef-lashing/bootstrap.json -O 	/etc/chef/bootstrap.json
sudo wget https://s3-us-west-2.amazonaws.com/chef-lashing/client.rb -O /etc/chef/client.rb
sudo wget https://s3-us-west-2.amazonaws.com/chef-lashing/validation.pem -O /etc/chef/validation.pem
sudo /usr/bin/chef-client -j /etc/chef/bootstrap.json
