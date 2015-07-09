json.partial! "api_partials/default_result"

if @error_code.nil?
  json.data do
    json.array! @cities, partial: "api_partials/city", as: :city
  end
end
