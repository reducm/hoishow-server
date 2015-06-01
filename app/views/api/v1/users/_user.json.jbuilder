<%# encoding: utf-8 %>

json.(user, :mobile, :api_token, :api_expires_in)
json.nickname user.nickname || ''
json.sex user.sex || ''
json.avatar user.avatar_url || ''
json.birthday user.birthday.to_ms rescue nil
