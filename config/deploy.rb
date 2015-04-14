lock '3.4.0'

set :stages, ["staging", "production"]
set :default_stage, "staging"
set :whenever_environment,  ->{ fetch :rails_env, fetch(:stage, "staging") }
set :whenever_roles, ->{ [:db, :app] }

set :sidekiq_monit_default_hooks, false

set :linked_files, %w{config/database.yml config/secrets.yml}
# set the locations that we will look for changed assets to determine whether to precompile
set :assets_dependencies, %w(app/assets lib/assets vendor/assets Gemfile.lock config/routes.rb)

namespace :deploy do
  task :compile_assets, :roles => :web do
    run "cd #{deploy_to}/current/; bundle exec rake assets:precompile && bundle exec rake assets:cdn"
  end

  after :finishing, 'deploy:cleanup'
end