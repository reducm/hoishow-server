json.(user, :mobile, :api_token, :api_expires_in, :nickname, :sex, :birthday)
json.avatar user.avatar.url rescue nil
