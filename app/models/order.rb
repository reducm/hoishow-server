#encoding: UTF-8
class Order < ActiveRecord::Base
  belongs_to :user
  #Order创建的时候，要保存concert, stadium,city,star,show的name和id，用冗余避免多表查询
  #seats_info 例: 12:10.0|25:230.0|, 约定格式 area_id:price|area_id2:price|area_id3:price, 类似单车的seat_info, 不过hoishow是复数。price的来源是show与area的中间表show_area_relations, 把price保存下来的好处是，以后查orders时，不需要再从庞大的中间表读数据，area_id则可以从area表去把数据区名读取出来
  #
  belongs_to :show

  validates :user, presence: {message: "User不能为空"}
  validates :seats_info, presence: true

  ASSOCIATION_ATTRS = [:city, :concert, :stadium, :star, :show]

  validates_presence_of ASSOCIATION_ATTRS.map{|sym| ( sym.to_s + "_name" ).to_sym}

  after_create :set_attr_after_create

  class << self
    def init_from_data(city: nil, concert: nil, stadium: nil, star: nil, show: nil )
      #方便把参数_name设到model
      hash = {}
      ASSOCIATION_ATTRS.each do |sym|
        hash[( sym.to_s + "_name" ).to_sym] = eval(sym.to_s).name
        hash[( sym.to_s + "_id" ).to_sym] = eval(sym.to_s).id
      end
      new(hash)
    end
  end

  def set_seats_and_price(show_area_relations)
    arr = show_area_relations.map  do |relation|
     "#{relation.area_id}:#{relation.price}" 
    end
    self.seats_info = arr.join("|")
    self.amount = show_area_relations.map{|relation| relation.price.to_f}.inject(&:+)
    save!
  end

  def seats_count
    seats_info.split("|").size
  end

  private
  def set_attr_after_create
    generate_out_id
    self.valid_time = Time.now + 15.minutes
    save!
  end

  def generate_out_id
    t = Time.now
    self.out_id = t.strftime('%Y%m%d%H%M') + "OR" + self.id.to_s.rjust(6, '0')
  end
end
