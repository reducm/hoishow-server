class District < ActiveRecord::Base
  has_many :stadiums
  belongs_to :city
end
