#encoding: UTF-8
class UserMessageRelation < ActiveRecord::Base
  belongs_to :user
  belongs_to :message

  validates :user, presence: {message: "User不能为空"}
  validates :message, presence: {message: "Message不能为空"}
end
