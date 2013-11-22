set :stage, :staging
set :deploy_to, "/var/www/projects/hatchboy/#{fetch(:stage)}"
set :upstart_script, "#{fetch(:application)}-#{fetch(:stage)}"

server 'shakuro.com', user: fetch(:user), roles: %w{web app db}

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:web), in: :sequence, wait: 5 do
      execute <<-FOREMAN
        cd #{release_path}
        /home/hatchboy/.rvm/bin/rvmsudo bundle exec foreman export upstart /etc/init -a #{fetch(:upstart_script)} -u #{fetch(:user)} -l /var/log/#{fetch(:upstart_script)}
        sudo start #{fetch(:upstart_script)} || sudo restart #{fetch(:upstart_script)}
      FOREMAN
    end
  end
end
