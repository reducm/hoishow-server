json.partial! "api_partials/default_result"

if @error_code.nil?
  json.data do
    json.array! @events, partial: "api_partials/event", as: :event
  end
end
