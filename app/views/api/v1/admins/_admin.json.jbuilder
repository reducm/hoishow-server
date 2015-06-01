# encoding: utf-8
json.(admin, :id, :name, :admin_type)
json.email admin.email || ""
json.last_sign_in_at admin.last_sign_in_at.to_ms
