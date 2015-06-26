module ApiAuthHelper
  def default_key
    ApiAuth.where(user: "fuck").first_or_create.key
  end

  def with_key(hash = {})
    hash.merge(key: default_key)
  end
end
