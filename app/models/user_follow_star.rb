#encoding: UTF-8
class UserFollowStar < ActiveRecord::Base
  belongs_to :user
  belongs_to :star
end
