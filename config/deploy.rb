# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'foodholic'
# Default value for :scm is :git
set :scm, :git

set :repo_url, 'git@bitbucket.org:vacationlabs/ankita-recipe-project.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/html/recipe-app' 
set :deploy_to, '/var/www/html/recipe-app-thin' #for thin server
# Default value for :pty is false
set :pty, true

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug


# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" } 
set :rails_env, "production"

set :linked_dirs, %w{tmp/pids}
set :linked_dirs, fetch(:linked_dirs, []).push('public/system')
# set :delayed_job_server_role, :worker
# set :delayed_job_args, "-n 2"

set :delayed_job_workers, 2

# set :delayed_job_prefix, :reports   

set :delayed_job_queues, ['mailer','tracking']

# set :delayed_job_pools, {
#     :mailer => 2,
#     :tracking => 1,
#     :* => 2
# }

# set :delayed_job_roles, [:app, :background]

set :delayed_job_bin_path, 'script'
 

after 'deploy', 'deploy:restart'

after 'deploy:published', 'restart' do
  invoke 'delayed_job:restart'
end
