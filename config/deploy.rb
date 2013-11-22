set :application, 'hatchboy'
set :user, 'hatchboy'

set :stages, %w(staging production)

set :repo_url, 'git@github.com:kstepanov/hatchboy.git'
set :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# set :default_stage, 'staging'
# set :pty, true

set :linked_files, %w{config/database.yml .env}
set :keep_releases, 3

namespace :deploy do
  after :finishing, 'deploy:cleanup'
end
