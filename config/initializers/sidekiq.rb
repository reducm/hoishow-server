redis_host = Rails.env.production? ? 'redis://10.6.21.209:6379' : 'redis://127.0.0.1:6379'


Sidekiq.configure_client do |config|
  config.redis = { url: redis_host, size: 2, namespace: 'hoishowsidekiq' }
end
Sidekiq.configure_server do |config|
  config.redis = { url: redis_host, size: 25, namespace: 'hoishowsidekiq' }
end

Sidekiq.logger = Yell.new do |l|
  l.level = 'gte.info'

  l.adapter :datefile, "#{Rails.root.join("log", "sidekiq.log")}", level: 'lte.error', keep: 5
  l.adapter :datefile, "#{Rails.root.join("log", "error.log")}", level: 'gte.error', keep: 5
end
