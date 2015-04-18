module Operation::UsersHelper
  def get_avatar(user)
    if user.avatar.url
      image_tag(user.avatar.url, class: 'img-responsive')
    else
      image_tag("/coldplay.png", class: 'img-responsive')
    end
  end
end
