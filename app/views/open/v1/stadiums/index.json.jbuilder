json.partial! "api_partials/default_result"

if @error_code.nil?
  json.data do
    json.array! @stadiums, partial: "api_partials/stadium", as: :stadium
  end
end
