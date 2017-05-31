yum_repository 'nginx-repo' do
  description "Yum repo for Nginx"
  baseurl "http://nginx.org/packages/centos/7/$basearch/"
  gpgcheck false
  enabled true
  action :create
end

package 'nginx' do
end

service 'nginx' do
action [ :enable, :start]
end
