@express = @user ? @user.expresses.last : nil

json.(order, :out_id, :amount, :concert_name, :concert_id, :stadium_name, :stadium_id, :show_name, :show_id, :city_name, :city_id, :status)
json.poster order.show.poster_url || ''
json.order_address order.user_address || ''
json.tickets_count order.tickets_count
json.show_time order.show.show_time.to_ms rescue nil
json.ticket_type order.show.ticket_type rescue ''
json.qr_url show_for_qr_scan_api_v1_order_path(order)
# json.ticket_pic order.show.ticket_pic_url || ''
json.valid_time order.valid_time.to_ms rescue nil

# about express
# json.express_id @express.id rescue ''
# json.district_address @express.district rescue ''
# json.user_name order.user_name || @express.user_name rescue ''
# json.user_mobile order.user_mobile || @express.user_mobile rescue ''
# json.express_code order.express_id || ''
# json.user_address @express.user_address rescue ''
# json.province_address @express.province rescue ''
# json.city_address @express.city rescue ''

# about tickets
json.tickets { json.array! order.tickets, partial: "api_partials/ticket", as: :ticket }
