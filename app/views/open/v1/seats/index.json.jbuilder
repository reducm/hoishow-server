json.partial! "api_partials/default_result"

if @error_code.nil?
  json.data do
    json.array! @seats, partial: "api_partials/seat", as: :seat
  end
end
