# 兼容以前的 seat model,
class Seat < Ticket
  alias_attribute :name, :seat_name
  alias_attribute :status, :seat_type
  serialize :channels

  skip_callback :save, :before, :generate_code
end
