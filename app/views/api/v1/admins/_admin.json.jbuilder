json.(admin, :id, :name, :admin_type, :api_token)
json.email admin.email || ""
json.last_sign_in_at admin.last_sign_in_at.to_ms rescue ''
