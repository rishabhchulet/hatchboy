set :application, 'hatchboy'
set :user, 'hatchboy'

set :stages, %w(staging production)
# set :default_env, { path: '$HOME/.rvm/bin:$PATH' }

set :repo_url, 'git@github.com:kstepanov/hatchboy.git'
set :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :pty, true
set :forward_agent, true

set :linked_files, %w{config/database.yml .env}
set :keep_releases, 3

# set :bundle_gemfile, -> { release_path.join('Gemfile') }
# set :bundle_dir, -> { shared_path.join('bundle') }
# set :bundle_flags, '--deployment --quiet'
# set :bundle_without, %w{test}.join(' ')
# set :bundle_binstubs, -> { shared_path.join('bin') }
# set :bundle_roles, :all
set :bundle_bins, %w(gem rake ruby foreman)

