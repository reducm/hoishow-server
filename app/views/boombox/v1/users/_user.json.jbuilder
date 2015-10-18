json.(user, :id, :api_token, :mobile, :email)
json.nickname user.nickname || ''
json.avatar user.avatar_url || ''
