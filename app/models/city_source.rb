class CitySource < ActiveRecord::Base
  belongs_to :city
  validates :name, :presence => true

  enum source: {
    hoishow: 0, # 自有资源
    damai: 1, # 大麦
    yongle: 2, # 永乐
    weipiao: 3 # 微票
  }
end
