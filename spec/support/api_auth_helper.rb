module ApiAuthHelper
  def default_key
    ApiAuth.create(user: "fuck").key
  end

  def with_key(hash)
    hash.merge(key: default_key)
  end
end
