<%# encoding: utf-8 %>

json.array! @shows, partial: "api/v1/shows/show", as: :show
