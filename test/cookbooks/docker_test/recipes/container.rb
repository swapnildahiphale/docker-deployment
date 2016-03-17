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
  tag 'latest'
  action :pull
end



#######
# linkd containers
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


# When we deploy the redis container links are broken and we
# have to redeploy the linked containers to fix them.
execute 'redeploy_link_source' do
  command 'touch /marker_container_redeploy_link_source'
  creates '/marker_container_redeploy_link_source'
  notifies :redeploy, 'docker_container[redis]'
  notifies :redeploy, 'docker_container[node1]'
  notifies :redeploy, 'docker_container[node2]'
  notifies :redeploy, 'docker_container[nginx]'
  action :run
end