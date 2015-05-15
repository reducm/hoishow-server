class Message < ActiveRecord::Base
  has_many :user_message_relation
  has_many :target_users, through: :user_message_relation, source: :user

  validates :creator_id, presence: true
  validates :creator_type, presence: true
  validates :subject_type, presence: true
  validates :content, presence: true
  validates :subject_id, presence: true

  paginates_per 20

  enum type: {
    new_show: 0, #有新show时的通知
    all_users_buy: 1, #开放所有用户买票的通知
    new_concert: 2, #有新concert时的通知
    comment_reply: 3, #回覆评论的通知
    topic_reply: 4, #回覆主题的通知
    manual: 5 #手动推送通知
  }

  def creator_type_cn
    case creator_type
    when 'All'
      '全部用户'
    when 'Concert'
      '关注concert的用户'
    when 'Show'
      '关注show的用户'
    when 'Star'
      '关注star的用户'
    end
  end

end
