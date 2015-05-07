module Operation::UsersHelper
  def get_avatar(user)
    if user.avatar_url
      image_tag(user.avatar_url)
    else
      image_tag("/default_avatar.png")
    end
  end
end
