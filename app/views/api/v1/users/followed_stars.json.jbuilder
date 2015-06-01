<%# encoding: utf-8 %>

json.array! @stars, partial: "api/v1/stars/star", as: :star
