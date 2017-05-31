# See https://docs.getchef.com/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "lashin"
client_key               "#{current_dir}/lashin.pem"
chef_server_url          "https://instance-2.c.acquired-shape-169217.internal/organizations/lashin-org"
cookbook_path            ["#{current_dir}/../cookbooks"]
