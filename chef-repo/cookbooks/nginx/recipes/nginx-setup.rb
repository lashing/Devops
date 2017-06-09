yum_repository 'nginx-repo' do
  description "Yum repo for Nginx"
  baseurl "http://nginx.org/packages/centos/7/$basearch/"
  gpgcheck false
  enabled true
  action :create
end

package 'nginx' do
end

template '/etc/nginx/conf.d/default.conf' do
  source 'default.conf.erb'
  mode '0755'
  owner 'root'
  group 'root'
end

service 'nginx' do
action [ :enable, :start]
end
