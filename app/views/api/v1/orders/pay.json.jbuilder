json.order {json.partial! "order", {order: @order}}

json.payment @payment.payment_type
case @payment.payment_type
when "alipay"
  json.data do
    json.query_string @query_string
  end
when "wxpay"
  json.data @sign
end