#encoding: UTF-8
class UserFollowConcert < ActiveRecord::Base
  belongs_to :user
  belongs_to :concert
end
