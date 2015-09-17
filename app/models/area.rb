#encoding: UTF-8
class Area < ActiveRecord::Base
  acts_as_cached(:version => 1, :expires_in => 1.day)

  SEAT_AVALIABLE = 'avaliable'
  SEAT_LOCKED = 'locked'
  SEAT_UNUSED = 'unused'

  belongs_to :stadium

  has_many :show_area_relations, dependent: :destroy
  has_many :shows, through: :show_area_relations
  has_many :tickets
  # 删除 seat 以后再改这里
  has_many :seats
  #with_options dependent: :destroy do |option|
    #option.has_many :seats, -> { where(order_id: nil) }
  #end

  validates :stadium, presence: {message: "场馆不能为空"}

  paginates_per 10

  def seats_info=(si)
    write_attribute(:seats_info, ActiveSupport::JSON::encode(si))
  end

  def seats_info
    si = read_attribute(:seats_info)
    return si if si.nil? || si == ''
    ActiveSupport::JSON::decode(si)
  end

  def select_from_seats_info(keys)
    return nil if self.seats_info.nil?

    self.seats_info['seats'].select{ |k, v| keys.to_a.include?(k) }
  end

  # 统计方法, for 兼容 wapper
  def avaliable_and_locked_seats_count
    status_statistics([SEAT_AVALIABLE, SEAT_LOCKED], 'status').size
  end

  def avaliable_seats_count
    status_statistics([SEAT_AVALIABLE], 'status').size
  end

  def status_statistics(filter=[], type)
    return 0 if self.seats_info.nil?

    self.seats_info['seats'].select{ |k, v| filter.include?(v[type]) }
  end

  def all_price_with_seats
    return [] if self.seats_info.nil?

    self.seats_info['seats'].map{|k,v| v['price'].to_i}
  end

  def draw_seats_info_for_apis(channel)
    return [] if self.seats_info.nil?

    seats = self.seats_info['seats']
    # sort_by = self.seats_info['sort_by']
    # total = self.seats_info['total'].split('|').map(&:to_i)
    # max_row, max_col= total[0], total[1]
    # 暂时不排序
    seats.each_pair do |k, v|
      row_col = k.split('|')
      hash = {}.tap do |h|
        h[:id] = 1 # hardcode seat id 兼容 api
        h[:row] = row_col[0]
        h[:column] = row_col[1]
        h[:name] = v['seat_no']
        h[:price] = v['price'].to_f
        # 非本渠道 seat, 状态全部设为 locked
        h[:status] = if seat.channels.include?(channel)
          v['status']
        else
          SEAT_LOCKED
        end
      end
    end
  end
end
