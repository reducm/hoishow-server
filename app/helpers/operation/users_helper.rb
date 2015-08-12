module Operation::UsersHelper
  def get_avatar(user, size)
    if user.avatar_url
      image_tag(user.avatar_url, size: size)
    else
      image_tag("/default_avatar.png", size: size)
    end
  end
end
