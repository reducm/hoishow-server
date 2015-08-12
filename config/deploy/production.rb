require "capistrano/rvm"
require "capistrano/bundler"

system "ssh-add"

set :application, "hoishow-server"
set :deploy_via, :remote_cache
set :repo_url, "git@git.bestapp.us:root/hoishow-server.git"

set :scm, :git
set :branch, "master"

set :use_sudo, false
set :user, 'deploy'
set :rails_env, "production"
set :deploy_to, '/data/deploy/hoishow-server'

set :assets_roles, [:web, :app]   # Defaults to [:web]
set :assets_prefix, 'assets'      # Defaults to 'assets' this should match config.assets.prefix in your rails config/application.rb

server '10.6.31.207', user: 'deploy', roles: %w{web app db}
server '10.6.23.41', user: 'deploy', roles: %w{web app db}
set :git_shallow_clone, 1
