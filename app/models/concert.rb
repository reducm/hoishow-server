class Concert < ActiveRecord::Base
  has_many :videos
  has_many :shows
end
