set :stage, :staging
set :deploy_to, "/var/www/projects/hatchboy/staging"
set(:upstart_script) { "#{application}-#{padrino_env}" }

server 'shakuro.com', user: 'hatchboy', roles: %w{web app db}


namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:web), in: :sequence, wait: 5 do
      run "cd #{release_path} && rvmsudo bundle exec foreman export upstart /etc/init -a #{upstart_script} -u #{user} -l /var/log/#{upstart_script}"
      run "sudo start #{upstart_script} || sudo restart #{upstart_script}"
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end
end


# namespace :foreman do
#   desc "Export the Procfile to Ubuntu's upstart scripts"
#   task :export do
#     on roles(:app) do
#       run "cd #{release_path} && rvmsudo bundle exec foreman export upstart /etc/init -a #{upstart_script} -u #{user} -l /var/log/#{upstart_script}"
#     end  
#   end
  
#   task :start do
#     on roles(:app) do
#       sudo "start #{upstart_script}"
#     end  
#   end

#   task :stop do
#     on roles(:app) do
#       sudo "stop #{upstart_script}"
#     end  
#   end

#   task :restart do
#     on roles(:app) do
#       run "sudo start #{upstart_script} || sudo restart #{upstart_script}"
#     end  
#   end
# end

# you can set custom ssh options
# it's possible to pass any option but you need to keep in mind that net/ssh understand limited list of options
# you can see them in [net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start)
# set it globally
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
# and/or per server
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
# setting per server overrides global ssh_options

# fetch(:default_env).merge!(rails_env: :staging)
