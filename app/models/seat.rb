class Seat < ActiveRecord::Base
  belongs_to :show
  belongs_to :area
end
