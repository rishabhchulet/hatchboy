set :stage, :staging2
set :rails_env, :staging

set :deploy_to, "/var/www/projects/hatchboy/#{fetch(:stage)}"
set :upstart_script, "#{fetch(:application)}-#{fetch(:stage)}"
set :rvm_type, :user

server 'shakuro.com', user: fetch(:user), roles: %w{web app db}

namespace :deploy do
  desc 'Restart application'
  task :restart do
    invoke :'foreman:export'
    invoke :'foreman:restart'
  end
end
