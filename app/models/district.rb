class District < ActiveRecord::Base
  has_many :stadiums
  belongs_to :city
  validates :name, uniqueness: {scope: :city_id}
end
