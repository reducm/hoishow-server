#encoding: UTF-8
class ApiAuth < ActiveRecord::Base
  #channel
  APP_IOS = 'hoishowIOS'
  APP_ANDROID = 'hoishowAndroid'
  DANCHE_SERVER = 'dancheServer'

  validates :user, presence: true, uniqueness: true
  validates :key, presence: true, uniqueness: true
  validates :secretcode, presence: true, uniqueness: true, if: :require_secretcode?
  before_validation :create_key
  before_validation :create_secretcode, if: :require_secretcode?

  scope :other_channels, -> {where('user != ? and user != ?', APP_ANDROID, APP_IOS)}

  def user
    super
  end
  alias :channel :user

  def require_secretcode?
    [DANCHE_SERVER].include? self.channel
  end

  def app_platform
    if self.user == APP_ANDROID
      "android"
    elsif self.user == APP_IOS
      "ios"
    end
  end

  #生成签名
  def generated_sign(params = {})
    #如果传入的参数是文档中规定的必需参数
    #将其组成字符串，格式为"key1=value1&key2=value2&...secretcode"
    #对字符串md5加密，加密后转成大写
    signing_string = params.sort.to_h.map{|key, value| "#{key.to_s}=#{value}"}.join("&") << self.secretcode
    signing_string = Digest::MD5.hexdigest(signing_string).upcase
  end

  protected
  def create_key
    self.key = SecureRandom.urlsafe_base64 if self.key.blank?
  end

  def create_secretcode
    self.secretcode = SecureRandom.urlsafe_base64 if self.secretcode.blank?
  end
end
