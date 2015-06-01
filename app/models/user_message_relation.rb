#encoding: UTF-8
class UserMessageRelation < ActiveRecord::Base
  belongs_to :user
  belongs_to :message

  validates :user, presence: {message: "用户不能为空"}
  validates :message, presence: {message: "消息不能为空"}
end
