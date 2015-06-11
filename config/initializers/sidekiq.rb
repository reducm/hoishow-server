if Rails.env.development? || Rails.env.test?
  Sidekiq.configure_server do |config|
    config.redis = { url: 'redis://localhost:6379/12'  }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: 'redis://localhost:6379/12'  }
  end
elsif Rails.env.staging?
  Sidekiq.configure_client do |config|
    config.redis = { :size => 2, :namespace => 'hoishowslidekiq' }
  end
  Sidekiq.configure_server do |config|
    config.redis = { :size => 25, :namespace => 'hoishowslidekiq' }
  end
elsif Rails.env.production?
  #TODO
end

Sidekiq.logger = Yell.new do |l|
  l.level = 'gte.info'

  l.adapter :datefile, "#{Rails.root.join("log", "sidekiq.log")}", level: 'lte.error', keep: 5
  l.adapter :datefile, "#{Rails.root.join("log", "error.log")}", level: 'gte.error', keep: 5
end
