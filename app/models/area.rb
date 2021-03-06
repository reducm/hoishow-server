#encoding: UTF-8
class Area < ActiveRecord::Base
  SEAT_AVALIABLE = 'avaliable'
  SEAT_LOCKED = 'locked'
  SEAT_UNUSED = 'unused'

  belongs_to :stadium
  belongs_to :event, touch: true
  has_many :show_area_relations, dependent: :destroy
  has_many :shows, through: :show_area_relations
  has_many :tickets, dependent: :destroy
  # 删除 seat 以后再改这里
  has_many :seats
  #with_options dependent: :destroy do |option|
    #option.has_many :seats, -> { where(order_id: nil) }
  #end

  enum source: {
    hoishow: 0, # 自有资源
    damai: 1, # 大麦
    yongle: 2, # 永乐
    weipiao: 3, # 微票
    viagogo: 4 # viagogo
  }

  paginates_per 10

  def show_time
    event.show_time rescue nil
  end

  def relation
    show_area_relations.first
  end

  def show
    shows.first
  end

  def seats_info=(si)
    write_attribute(:seats_info, ActiveSupport::JSON::encode(si))
  end

  def seats_info
    si = read_attribute(:seats_info)
    return si if si.nil? || si == ''
    ActiveSupport::JSON::decode(si)
  end

  def select_from_seats_info(keys) # keys = ["row|col", "row|col"]
    return nil if self.seats_info.nil?

    {}.tap do |h|
      keys.each do |k|
        rc_key = k.split('|')
        value = { k => self.seats_info['seats'][rc_key[0]][rc_key[1]] } rescue {}
        h.merge!(value)
      end
    end

    # self.seats_info['seats'].select{ |k, v| keys.to_a.include?(k) }
  end

  # 统计方法, for 兼容 wapper
  def avaliable_and_locked_seats_count
    status_statistics([SEAT_AVALIABLE, SEAT_LOCKED], 'status').sum{|i| i.size}
  end

  def avaliable_seats_count
    status_statistics([SEAT_AVALIABLE], 'status').sum{|i| i.size}
  end

  def status_statistics(filter=[], type)
    return 0 if self.seats_info.nil?

    self.seats_info['seats'].map{ |k1, v1| v1.select{ |k2, v2| filter.include?(v2[type]) } }
  end

  def all_price_with_seats
    return [] if self.seats_info.nil?

    self.seats_info['seats'].flat_map{ |k1, v1| v1.map { |k2, v2| v2['price'].to_i } }.uniq
  end

  # def draw_seats_info_for_apis(channel)
  #   return [] if self.seats_info.nil?
  #
  #   seats = self.seats_info['seats']
  #   # sort_by = self.seats_info['sort_by']
  #   # total = self.seats_info['total'].split('|').map(&:to_i)
  #   # max_row, max_col= total[0], total[1]
  #   # 暂时不排序
  #   seats.each_pair do |k, v|
  #     row_col = k.split('|')
  #     hash = {}.tap do |h|
  #       h[:id] = 1 # hardcode seat id 兼容 api
  #       h[:row] = row_col[0]
  #       h[:column] = row_col[1]
  #       h[:name] = v['seat_no']
  #       h[:price] = v['price'].to_f
  #       # 非本渠道 seat, 状态全部设为 locked
  #       h[:status] = if seat.channels.include?(channel)
  #         v['status']
  #       else
  #         SEAT_LOCKED
  #       end
  #     end
  #   end
  # end
end
