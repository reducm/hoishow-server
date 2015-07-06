module ApiAuthHelper

  def default_key
    ApiAuth.where(user: "fuck").first_or_create.key
  end

  def default_secretcode
    ApiAuth.where(user: "fuck").first_or_create.secretcode
  end

  def timestamp
    Time.now.to_i 
  end

  def sign
    Digest::MD5.hexdigest("api_key=#{default_key}&timestamp=#{timestamp}#{default_secretcode}")
  end

  def with_key(hash = {})
    hash.merge(key: default_key)
  end

  def with_out_channel_params(hash = {})
    hash.merge(api_key: default_key, timestamp: timestamp, sign: sign)
  end
end
