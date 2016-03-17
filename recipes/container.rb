###################
# Put docker files
###################
template "/root/docker-workflow/node/Dockerfile" do
  source "node-dockerfile"
end

template "/root/docker-workflow/nginx/Dockerfile" do
  source "nginx-dockerfile"
end

template "/root/docker-workflow/redis/Dockerfile" do
  source "redis-dockerfile"
end


###################
#Build docker images
###################
docker_image 'node' do
  tag 'v0.1.0'
  source '/root/docker-workflow/node'
  action :build
end

docker_image 'nginx' do
  tag 'v0.1.0'
  source '/root/docker-workflow/nginx'
  action :build
end

docker_image 'redis' do
  tag 'v0.1.0'
  source '/root/docker-workflow/redis'
  action :build
end



#######
# links
#######

# docker inspect -f "{{ .Config.Env }}" link_source
# docker inspect -f "{{ .NetworkSettings.IPAddress }}" link_source
docker_container 'redis' do
  repo 'redis'
  action :run
end

docker_container 'node1' do
  repo 'node'
  tag 'v0.1.0'
  links ['redis:redis']
  action :run
end

docker_container 'node2' do
  repo 'node'
  tag 'v0.1.0'
  links ['redis:redis']
  action :run
end

docker_container 'nginx' do
  repo 'nginx'
  tag 'v0.1.0'
  port '80:80'
  links ['node1:node1']
  action :run
end
#docker_container 'link_source_2' do
#  repo 'alpine'
#  tag '3.1'
#  env ['FOO=few', 'BIZ=buzz']
#  command 'sh -c "trap exit 0 SIGTERM; while :; do sleep 1; done"'
#  port '322'
#  kill_after 1
#  action :run
#end

# docker inspect -f "{{ .HostConfig.Links }}" link_target_1
# docker inspect -f "{{ .Config.Env }}" link_target_1
#docker_container 'link_target_1' do
#  repo 'alpine'
#  tag '3.1'
#  env ['ASD=asd']
#  command 'ping -c 1 hello'
#  links 'link_source:hello'
#  subscribes :run, 'docker_container[link_source]'
#  action :run_if_missing
#end

# docker logs linker_target_2
#docker_container 'link_target_2' do
#  repo 'alpine'
#  tag '3.1'
#  command 'env'
#  links ['link_source:hello']
#  subscribes :run, 'docker_container[link_source]'
#  action :run_if_missing
#end

# docker logs linker_target_3
#docker_container 'link_target_3' do
#  repo 'alpine'
#  tag '3.1'
#  env ['ASD=asd']
#  command 'ping -c 1 hello_again'
#  links ['link_source:hello', 'link_source_2:hello_again']
#  subscribes :run, 'docker_container[link_source]'
#  subscribes :run, 'docker_container[link_source_2]'
#  action :run_if_missing
#end

# docker logs linker_target_4
#docker_container 'link_target_4' do
#  repo 'alpine'
#  tag '3.1'
#  command 'env'
#  links ['link_source:hello', 'link_source_2:hello_again']
#  subscribes :run, 'docker_container[link_source]'
#  subscribes :run, 'docker_container[link_source_2]'
#  action :run_if_missing
#end

# When we deploy the link_source container links are broken and we
# have to redeploy the linked containers to fix them.
execute 'redeploy_link_source' do
  command 'touch /marker_container_redeploy_link_source'
  creates '/marker_container_redeploy_link_source'
  notifies :redeploy, 'docker_container[redis]'
  notifies :redeploy, 'docker_container[node1]'
  notifies :redeploy, 'docker_container[node2]'
  notifies :redeploy, 'docker_container[nginx]'

#  notifies :redeploy, 'docker_container[link_target_2]'
#  notifies :redeploy, 'docker_container[link_target_3]'
#  notifies :redeploy, 'docker_container[link_target_4]'
  action :run
end