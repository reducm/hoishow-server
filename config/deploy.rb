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

set :linked_dirs, %w{tmp/pids tmp/cache tmp/sockets}
# set the locations that we will look for changed assets to determine whether to precompile
set :assets_dependencies, %w(app/assets lib/assets vendor/assets Gemfile.lock config/routes.rb)

set :local_tmp_path, 'config/deploy/tmp/'

set :keep_releases, 5

def rsync(role, from, to)
  options = [:rsync, '-av']
  options << "-e 'ssh -p #{role.port}'" unless role.port.nil?
  options << from
  options << to
  execute *options
end

namespace :deploy do
  namespace :assets do
    def staged_assets_root_path
      Pathname.new(fetch(:staged_assets_path) || 'config/deploy/assets/')
    end

    Rake::Task["precompile"].clear_actions
    desc "Precompile assets locally and then rsync to deploy server"
    task :precompile do

      invoke 'deploy:assets:update_local_files_via_git'
      invoke 'deploy:assets:local_precompile'
    end

    task :update_local_files_via_git do
      run_locally{ execute :git, :pull, :origin, '`git rev-parse --abbrev-ref HEAD`' }
    end

    task :local_precompile do

      assets_prefix = fetch(:assets_prefix)

      assets_path = Pathname.new("./public/#{assets_prefix}")
      run_locally do
        execute :rm, '-rf', assets_path
        staged_asstes_path = staged_assets_root_path.join(fetch(:stage).to_s)
        execute :mkdir, '-p', staged_asstes_path
        execute :ln, '-s', staged_asstes_path.realpath, assets_path
        with rails_env: fetch(:rails_env) do
          rake 'assets:precompile'
          rake 'assets:clean'
        end
      end

      #remove all manifest incase there is more than 1 manifest file
      invoke 'deploy:assets:remove_manifest'
      invoke 'deploy:assets:upload_local_assets'

    end

    task :upload_local_assets do

      assets_prefix = fetch(:assets_prefix)
      run_locally do
        roles(*fetch(:assets_roles)).each do |role|
          rsync role, "./public/#{assets_prefix}/",
                  "#{role.user}@#{role.hostname}:#{release_path}/public/#{assets_prefix}/"
        end
      end
    end

    task :remove_manifest do
      on roles *fetch(:assets_roles) do
        execute :rm, '-f', release_path.join('public', 'assets', 'manifest*')
      end
    end
  end

  task :compile_assets do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "assets:publish_assets"
        end
      end
    end
  end
  after "deploy:assets:precompile", "deploy:compile_assets"

  after :finishing, 'deploy:cleanup'
end
