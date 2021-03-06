# 兼容以前的 seat model,
class Seat < Ticket
  alias_attribute :name, :seat_name
  alias_attribute :status, :seat_type
  serialize :channels

  scope :avaliable_and_locked_seats, ->{where('seat_type = ? or (seat_type = ? and order_id is not null)', Ticket::seat_types[:avaliable], Ticket::seat_types[:locked])}
  scope :avaliable_seats, ->{ where(status: Ticket::seat_types[:avaliable]) }
  scope :not_avaliable_seats, ->{ where(status: [Ticket::seat_types[:unused], Ticket::seat_types[:locked]]) }

  skip_callback :save, :before, :generate_code
end
