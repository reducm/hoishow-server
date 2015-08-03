require "capistrano/rvm"
require "capistrano/bundler"

system "ssh-add"

set :application, "hoishow-server"
set :deploy_via, :remote_cache
set :repo_url, "git@git.bestapp.us:root/hoishow-server.git"

set :scm, :git
set :branch, "staging"

set :use_sudo, false
set :user, 'deploy'
set :rails_env, "staging"
set :deploy_to, '/data/deploy/hoishow-server'

server '122.226.100.76', user: 'deploy', roles: %w{web app db}
set :git_shallow_clone, 1
