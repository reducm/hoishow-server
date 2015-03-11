class Show < ActiveRecord::Base
  belongs_to :concert
  belongs_to :city
  belongs_to :stadium

  has_many :show_area_relations
  has_many :areas, through: :show_area_relations
end
