#encoding: UTF-8
class ApiAuth < ActiveRecord::Base
  APP_IOS = 'hoishowIOS'
  APP_ANDROID = 'hoishowAndroid'

  validates :user, presence: true, uniqueness: true
  validates :key, presence: true, uniqueness: true
  before_validation :create_key

  scope :other_channels, -> {where('user != ? and user != ?', APP_ANDROID, APP_IOS)}

  def app_platform
    if self.user == APP_ANDROID
      "android"
    elsif self.user == APP_IOS
      "ios"
    end
  end

  protected
  def create_key
    self.key = SecureRandom.urlsafe_base64 if self.key.blank?
  end
end
