# config valid only for current version of Capistrano
lock '3.4.0'

set :stages, ["staging", "production"]
set :default_stage, "staging"

set :keep_releases, 5

set :linked_files, %w{config/database.yml config/secrets.yml}
set :assets_dependencies, %w(app/assets lib/assets vendor/assets Gemfile.lock config/routes.rb)

namespace :deploy do
  after :finishing, 'deploy:cleanup'
end