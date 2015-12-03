class BoomUserMessageRelation < ActiveRecord::Base
  belongs_to :user
  belongs_to :boom_message
end
