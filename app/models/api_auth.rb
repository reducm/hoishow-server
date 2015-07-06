#encoding: UTF-8
class ApiAuth < ActiveRecord::Base
  APP_IOS = 'hoishowIOS'
  APP_ANDROID = 'hoishowAndroid'

  validates :user, presence: true, uniqueness: true
  validates :key, presence: true, uniqueness: true
  validates :secretcode, presence: true, uniqueness: true, if: :is_other_channels?
  before_validation :create_key
  before_validation :create_secretcode, if: :is_other_channels?

  scope :other_channels, -> {where('user != ? and user != ?', APP_ANDROID, APP_IOS)}

  def is_other_channels?
    [APP_IOS, APP_ANDROID].exclude? self.user
  end

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

  def create_secretcode
    self.secretcode = SecureRandom.urlsafe_base64 if self.secretcode.blank?
  end
end
