#encoding: UTF-8
class UserFollowShow < ActiveRecord::Base
  belongs_to :user
  belongs_to :show
end
