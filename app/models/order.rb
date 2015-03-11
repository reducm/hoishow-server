#encoding: UTF-8
class Order < ActiveRecord::Base
  belongs_to :user
  #Order创建的时候，要保存concert, stadium,city,star,show的name和id，用冗余避免多表查询
  #seats_info 例: 12:10.0|25:230.0|, 约定格式 area_id:price|area_id2:price|area_id3:price, 类似单车的seat_info, 不过hoishow是复数。price的来源是show与area的中间表show_area_relations, 把price保存下来的好处是，以后查orders时，不需要再从庞大的中间表读数据，area_id则可以从area表去把数据区名读取出来
  #
  class << self
    def init_from_data(city: nil, concert: nil, stadium: nil, star: nil, show: nil )
      new(city_name: city.name, city_id: city.id, concert_name: concert.name, stadium_name: stadium.id, star_name: star.name, star_id: star.id, show_name: show.name, show_id: show.id)
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
end
