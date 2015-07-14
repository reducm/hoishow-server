json.partial! "api_partials/default_result"

if @error_code == 2004
  json.data do
    json.unavaliable_seats do
      json.array! @unavaliable_seats do |us|
        json.(us, :id, :name)
      end
    end
  end
end
