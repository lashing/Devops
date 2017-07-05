directory '/etc/nodejs' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

execute 'nodejs-repo setup' do
  command 'curl --silent --location https://rpm.nodesource.com/setup | bash -'
end

package %w(nodejs gcc-c++ make) do
end

template '/etc/nodejs/server.js' do
  source 'server.js.erb'
  mode '0755'
  owner 'root'
  group 'root'
end

execute 'nodejs-startup' do
  command 'nohup node /etc/nodejs/server.js >/var/log/nodeapp.log 2>&1 &'
end
