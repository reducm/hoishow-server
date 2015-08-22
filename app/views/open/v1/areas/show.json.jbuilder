json.partial! "api_partials/default_result"

if @error_code.nil?
  json.data do
    json.partial! "api_partials/area", area: @area, show: @show, need_seats: true
  end
end
