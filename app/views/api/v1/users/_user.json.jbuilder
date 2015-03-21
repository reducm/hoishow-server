json.(user, :mobile, :api_token, :api_expires_in, :nickname, :sex)
json.avatar user.avatar.url rescue nil
json.birthday user.birthday.to_ms rescue nil
