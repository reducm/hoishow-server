require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'csv'
require 'elasticsearch/rails/instrumentation'

ActiveRecord::Base.raise_in_transactional_callbacks = true

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HoishowServer
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths += %W(#{config.root}/lib)
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Beijing'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :"zh-CN"

    # Do not swallow errors in after_commit/after_rollback callbacks.
    # config.active_record.raise_in_transactional_callbacks = true
    Rails.application.config.assets.precompile += %w( boombox_operation.css boombox_operation.js operation.css operation.js mobile.css mobile.js seats_map.css seats_map.js boombox_mobile.js boombox_mobile.css)
  end
end
