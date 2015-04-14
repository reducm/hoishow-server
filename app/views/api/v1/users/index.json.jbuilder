json.array! @users do |user|
  json.partial! "api/v1/users/user", locals: {user: user}
end


