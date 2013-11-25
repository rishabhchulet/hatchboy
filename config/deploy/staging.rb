set :stage, :staging
set :deploy_to, "/var/www/projects/hatchboy/#{fetch(:stage)}"
set :upstart_script, "#{fetch(:application)}-#{fetch(:stage)}"

set :rvm_type, :user

server 'shakuro.com', user: fetch(:user), roles: %w{web app db}

namespace :deploy do
  desc 'Restart application'
  task :restart do
    # on roles(:web), in: :sequence, wait: 5 do
    #   within release_path do
        invoke :'rvm:trust_rvmrc'
        invoke :'foreman:export'
        invoke :'foreman:restart'
        # execute :cd, release_path
        # execute :pwd, release_path
        # execute "~/.rvm/bin/rvm rvmrc trust #{release_path}"
        # # execute :cat, 'Gemfile'
        # execute "cd #{release_path} && ~/.rvm/bin/rvmsudo bundle exec foreman export upstart /etc/init -a #{fetch(:upstart_script)} -u #{fetch(:user)} -l /var/log/#{fetch(:upstart_script)}"
        # execute "sudo start #{fetch(:upstart_script)} || sudo restart #{fetch(:upstart_script)}"
        # execute <<-FOREMAN
        #   ~/.rvm/bin/rvm rvmrc trust #{release_path}
        #   sudo bundle exec foreman export upstart /etc/init -a #{fetch(:upstart_script)} -u #{fetch(:user)} -l /var/log/#{fetch(:upstart_script)}
        #   sudo start #{fetch(:upstart_script)} || sudo restart #{fetch(:upstart_script)}
        # FOREMAN
    #   end
    # end
  end
end
