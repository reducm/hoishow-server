lock '3.4.0'

set :stages, ["staging", "production"]
set :default_stage, "staging"
set :whenever_environment,  ->{ fetch :rails_env }
set :whenever_roles, ->{ [:db, :app] }

set :sidekiq_monit_default_hooks, false

namespace :deploy do
  after :finishing, 'deploy:cleanup'
end