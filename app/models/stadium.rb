class Stadium < ActiveRecord::Base
  has_many :areas
  belongs_to :city
end
