set :user, 'deploy'
set :domain, 'domain_or_ip'
set :deploy_to, '/home/deploy/project_name'
set :branch, ENV['branch'] || 'master'