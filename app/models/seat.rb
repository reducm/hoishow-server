# 兼容以前的 seat model,
class Seat < Ticket
  alias_attribute :name, :seat_name
  serialize :channels

  enum status: {
    avaliable: 0,  # 可选, 对应 Ticket.statuses[:pending]
    locked: 1,     # 不可选，对应 Ticket.statuses[:success]
    unused: 5      # 空白座位
  }

  skip_callback :save, :before, :generate_code
end
