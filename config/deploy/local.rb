# deploy 测试环境

require "capistrano/rvm"
require "capistrano/bundler"

# system "ssh-add"

set :application, "hoishow-server"
set :deploy_via, :remote_cache
set :repo_url, "git@git.bestapp.us:root/hoishow-server.git"

set :scm, :git
set :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :rails_env, "staging"

set :stage, :local

ip = 'localhost'

# Capistrano rails setting
set :rails_env, 'development'      # If the environment differs from the stage name
set :migration_role, 'db'         # Defaults to 'db'
set :assets_roles, [:web, :app]   # Defaults to [:web]
set :assets_prefix, 'assets'      # Defaults to 'assets' this should match config.assets.prefix in your rails config/application.rb

# Capistrano rvm setting
set :rvm_type, :auto                     # Defaults to: :auto
set :rvm_ruby_version, 'default'      # Defaults to: 'default'
#set :rvm_custom_path, '~/.myveryownrvm'  # only needed if not detected

set :deploy_to, '/Users/jed_huo/workspace/deploy/hoishow_test'

server ip, user: 'jed_huo', roles: %w{web app db}
#server '127.0.0.1', user: 'kevin', roles: %w{web app db}
