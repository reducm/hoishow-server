json.partial! "show", { show: @show }
json.topics do
  json.array! show.topics.limit(20) do |topic|
    json.partial! "api/v1/topics/topic", {topic: topic}
  end
end
