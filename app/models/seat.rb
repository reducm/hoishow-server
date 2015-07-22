# 兼容以前的 seat model,
class Seat < Ticket
  alias_attribute :name, :seat_name

  enum status: {
    avaliable: 5,  # 可选, 对应 Ticket.statuses[:pending]
    locked: 6,     # 不可选，对应 Ticket.statuses[:success]
    unused: 7      # 空白座位
  }

  skip_callback :save, :before, :generate_code

  private
  def set_status
    self.status = :avaliable if self.status.blank?
  end
end
