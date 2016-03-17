
################
# Docker service
################

docker_service 'default' do
  host 'unix:///var/run/docker.sock'
  install_method 'auto'
  service_manager 'auto'
  action [:create, :start]
end
#include_recipe 'docker_test:container'


##############
# install git
#############
package "git" do
	action :install
end

##############
# Clone repo if doesn't exists
##############
#execute 'Clone git repo first time' do
#	cwd '/root'
#    command 'git clone https://github.com/swapnildahiphale/docker-workflow.git'
#     not_if { Dir.exist?("/root/docker-workflow") }
#end

##############
# Pull latest code
##############

execute 'Clone git repo first time' do
	cwd '/root/docker-workflow'
    command 'git pull'
end

include_recipe 'docker_test::container'