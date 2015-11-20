class BoomMessage < ActiveRecord::Base
  default_scope {order('created_at DESC')}

  belongs_to :boom_admin

end
