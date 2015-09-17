json.partial! "api_partials/default_result"

if @error_code.nil?
  json.data do
    json.array! @show.seats.where(area_id: @area.id).order(:row, :column), partial: "api_partials/seat", as: :seat
  end
end
