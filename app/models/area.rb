class Area < ActiveRecord::Base
  belongs_to :stadium

  has_many :show_area_relations
  has_many :shows, through: :show_area_relations
end
