module ApiAuthHelper
  def default_key
    ApiAuth.where(user: "fuck").first_or_create.key
  end

  def with_key(hash = {})
    hash.merge(key: default_key)
  end

  def encrypted_params_in_open(options={})
    api_auth = ApiAuth.where(user: ApiAuth::DANCHE_SERVER).first_or_create

    options.merge!(api_key: api_auth.key)
    options.merge!(timestamp: Time.now.to_i)
    signing_string = options.sort.to_h.map{|key, value| "#{key.to_s}=#{value}"}
      .join("&") << api_auth.secretcode
    sign = Digest::MD5.hexdigest(signing_string).upcase
    options.merge!(sign: sign)
  end
end
