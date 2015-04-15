json.array! @tickets do |ticket|
  json.partial! "api/v1/tickets/ticket", locals: {ticket: ticket}
end


