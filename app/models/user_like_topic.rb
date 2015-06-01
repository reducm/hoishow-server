#encoding: UTF-8
class UserLikeTopic < ActiveRecord::Base
  belongs_to :user
  belongs_to :topic
end
