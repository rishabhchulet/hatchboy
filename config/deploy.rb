set :application, 'hatchboy'
set :user, application

set :stages, %w(staging production)
set :default_stage, 'staging'

set :repo_url, 'git@github.com:kstepanov/hatchboy.git'
set :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }


# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# set :deploy_to, '/var/www/my_app'
# set :scm, :git

# set :format, :pretty
# set :log_level, :debug
# set :pty, true

set :linked_files, %w{config/database.yml .env}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :keep_releases, 3

namespace :deploy do

  # desc 'Restart application'
  # task :restart do
  #   on roles(:app), in: :sequence, wait: 5 do
  #     # Your restart mechanism here, for example:
  #     # execute :touch, release_path.join('tmp/restart.txt')
  #   end
  # end

  # after :restart, :clear_cache do
  #   on roles(:web), in: :groups, limit: 3, wait: 10 do
  #     # Here we can do anything such as:
  #     # within release_path do
  #     #   execute :rake, 'cache:clear'
  #     # end
  #   end
  # end

  after :finishing, 'deploy:cleanup'

end


namespace :foreman do
  desc "Export the Procfile to Ubuntu's upstart scripts"
  task :export, :roles => :app do
    run "cd #{release_path} && rvmsudo bundle exec foreman export upstart /etc/init -a #{upstart_script} -u #{user} -l /var/log/#{upstart_script}"
  end
  
  task :start, :roles => :app do
    sudo "start #{upstart_script}"
  end

  task :stop, :roles => :app do
    sudo "stop #{upstart_script}"
  end

  task :restart, :roles => :app do
    run "sudo start #{upstart_script} || sudo restart #{upstart_script}"
  end
end