json.partial! "api_partials/default_result"

if @error_code.nil?
  json.data do
    json.partial! "api_partials/order", order: @order
  end
end
