class ApiAuth < ActiveRecord::Base
  validates :user, presence: true
  validates :key, presence: true, uniqueness: true
  before_validation :create_key

  protected
  def create_key
    self.key = SecureRandom.urlsafe_base64 if self.key.blank?
  end
end
