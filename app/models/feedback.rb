class Feedback < ActiveRecord::Base
  acts_as_cached(:version => 1, :expires_in => 1.week)
  default_scope {order('feedbacks.created_at DESC')}
  paginates_per 10
end
