lock '3.4.0'

set :stages, ["staging", "production"]
set :default_stage, "staging"
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }
set :whenever_roles, ->{ [:db, :app] }

set :sidekiq_monit_default_hooks, false
set :pty, false

set :linked_files, %w{config/database.yml config/settings/wx_pay.yml config/settings/alipay.yml
                      config/certs/rsa_private_key.pem config/certs/app_private_key.pem
                      config/certs/alipay_public_key.pem}
# set the locations that we will look for changed assets to determine whether to precompile
set :assets_dependencies, %w(app/assets lib/assets vendor/assets Gemfile.lock config/routes.rb)

namespace :deploy do
  task :compile_assets do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "assets:publish_assets"
          execute :rake, "kindeditor:assets"
        end
      end
    end
  end
  after "deploy:assets:precompile", "deploy:compile_assets"

  after :finishing, 'deploy:cleanup'
end
