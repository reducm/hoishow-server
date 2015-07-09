json.partial! "api_partials/default_result"

if @error_code.nil?
  json.data do
    json.array! @shows, partial: "api_partials/show", as: :show
  end
end
