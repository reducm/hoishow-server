#encoding: UTF-8
class Area < ActiveRecord::Base
  acts_as_cached(:version => 1, :expires_in => 1.day)

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
    return si unless si
    ActiveSupport::JSON::decode(si)
  end
end
