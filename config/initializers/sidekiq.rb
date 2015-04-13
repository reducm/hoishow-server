if Rails.env.development? || Rails.env.test?
  Sidekiq.configure_server do |config|
    config.redis = { url: 'redis://localhost:6379/12'  }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: 'redis://localhost:6379/12'  }
  end
elsif Rails.env.staging?
  #TODO
elsif Rails.env.production?
  #TODO
end
