module ApplicationHelper
  def boombox_default_avatar(img)
    if img
      image_tag(img)
    else
      image_tag('/boombox_default_avatar.png')
    end
  end

  def boombox_default_cover(img)
    if img
      image_tag(img)
    else
      image_tag('/boombox_default_cover.png')
    end
  end
end
