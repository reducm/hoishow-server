json.partial! "api_partials/default_result"

if @error_code.nil?
  json.data do
    json.array! @areas, partial: "api_partials/area", as: :area, show: @show
  end
end
