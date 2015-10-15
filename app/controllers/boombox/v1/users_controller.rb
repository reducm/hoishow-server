class Boombox::V1::UsersController < Boombox::V1::ApplicationController
  before_filter :check_login!, except: [:verification, :verified_mobile, :sign_up, :sign_in]

  def verification
    render json: { result: "success" }
  end

  def verified_mobile

  end

  def sign_up

  end

  def sign_in

  end

  def forgot_password

  end

  def reset_password

  end

  def update_user

  end

  def reset_mobile

  end

  def get_user

  end

  def followed_collaborators

  end

  def followed_playlists

  end

  def my_playlists

  end

  def comment_list

  end

  def message_list

  end

  def follow_subject

  end

  def unfollow_subject

  end

  def create_comment

  end
   
  def like_subject

  end

  def unlike_subject

  end

  def add_to_playlist

  end

  def create_playlist

  end
end
