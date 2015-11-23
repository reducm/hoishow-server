class MessageTask < ActiveRecord::Base
  default_scope {order('created_at')}
  belongs_to :boom_message
end
