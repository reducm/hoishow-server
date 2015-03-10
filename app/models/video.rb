class Video < ActiveRecord::Base
  belongs_to :star
  belongs_to :concert
end
