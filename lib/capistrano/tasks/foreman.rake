namespace :foreman do

  desc "Export the Procfile to Ubuntu's upstart scripts"
  task :export do
    on roles(:all) do 
      execute <<-INIT
        export rvmsudo_secure_path=0
        cd #{release_path}
        ~/.rvm/bin/rvmsudo ~/.rvm/bin/rvm default do bundle exec foreman export upstart /etc/init -a #{fetch(:upstart_script)} -u #{fetch(:user)} -l /var/log/#{fetch(:upstart_script)}
      INIT
    end
  end

  task :start do
    on roles(:web) do 
      execute "sudo start #{fetch(:upstart_script)}"
    end
  end

  task :stop do
    on roles(:web) do 
      execute "sudo stop #{fetch(:upstart_script)}"
    end
  end

  task :restart do
    on roles(:web) do 
      execute "sudo start #{fetch(:upstart_script)} || sudo restart #{fetch(:upstart_script)}"
    end
  end
end
