<%# encoding: utf-8 %>

if @startup
  json.partial! "startup", startup: @startup
end
