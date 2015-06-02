<%# encoding: utf-8 %>

json.array! @concerts, partial: "api/v1/concerts/concert", as: :concert
