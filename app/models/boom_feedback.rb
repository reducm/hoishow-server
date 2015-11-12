class BoomFeedback < ActiveRecord::Base
  acts_as_cached(:version => 1, :expires_in => 1.week)
  default_scope {order('boom_feedbacks.created_at DESC')}
  paginates_per 10

  belongs_to :user

  validates :content, length: { maximum: 500 }

  after_create :set_status

  #status为0即为等待处理，为1则为已经处理
  def set_status
    self.update(status: 0) if status.nil?
  end
end
