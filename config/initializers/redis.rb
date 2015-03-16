#Redis::Objects.redis = Redis.new(host:'10.4.5.208',port:6379)
if Rails.env.development? || Rails.env.test?
  Redis::Objects.redis = Redis.new(host:'localhost',port:6379)
elsif Rails.env.production?
  Redis::Objects.redis = Redis.new(host:'10.6.19.184',port:6379)
end
