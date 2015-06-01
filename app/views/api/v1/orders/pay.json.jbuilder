# encoding: utf-8
json.order {json.partial! "order", {order: @order}}

json.payment @payment.payment_type

case @payment.payment_type
when "alipay"
  json.query_string @query_string
when "wxpay"
  json.sign @sign
end
