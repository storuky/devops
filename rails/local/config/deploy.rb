require 'mina/rails'
require 'mina/git'
require 'mina/rvm'
require 'mina/puma'
require 'mina/multistage'

set :stages, %w(development test staging production)
set :stages_dir, 'config/deploy'
set :default_stage, 'production'

set :application_name, 'project_name'
set :repository, 'git@github.com:storuky/project_name.git'

set :forward_agent, false

set :shared_dirs, fetch(:shared_dirs, []).push('tmp', 'log')
set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/secrets.yml', 'config/puma.rb', '.env')

task :remote_environment do
  invoke :'rvm:use', 'ruby-2.6.3@project_name'
end

task :setup do
  #command %{rvm install 2.6.3 --skip-existing}
  #command %{rvm use ruby-2.6.3@lk --create}
end

desc "Deploys the current version to the server."
task :deploy do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        invoke :'puma:phased_restart'
      end
    end
  end
end