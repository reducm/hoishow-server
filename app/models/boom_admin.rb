#encoding: UTF-8
class BoomAdmin < ActiveRecord::Base
  include ModelAttrI18n

  has_many :boom_messages
  validates :admin_type, presence: true
  validates :name, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, if: :dj?

  enum admin_type: {
    admin: 0,
    operator: 1,
    dj: 2
  }

  # dj注册
  before_create :confirmation_token

  def sign_in_api
    return if self.api_token.present?

    self.api_token = SecureRandom.hex(16)
    self.last_sign_in_at = DateTime.now
    save!
  end

  def type_cn
    # admin: '管理员'
    # operator: '运营'
    # dj: 'dj'
    tran("admin_type")
  end

  def avatar_url
    "#{UpyunSetting["upyun_upload_url"]}/boombox_admin_avatar.png"
  end

  def default_name
    "播霸官方"
  end
  alias_method :show_name, :default_name

  def set_password(password)
    self.createHash(password)
  end

  def password_valid?(password)
    self.validatePassword(password)
  end

  # Returns a salted PBKDF2 hash of the password.
  def createHash(password)
    self.salt = SecureRandom.base64(24)
    pbkdf2 = OpenSSL::PKCS5::pbkdf2_hmac_sha1(password, self.salt, 1000, 24)
    self.encrypted_password = ["sha1", Base64.encode64(pbkdf2)].join(':')
  end

  # Checks if a password is correct given a hash of the correct one.
  # correctHash must be a hash string generated with createHash.
  def validatePassword(password)
    params = self.encrypted_password.split(':')
    return false if params.length != 2

    pbkdf2 = Base64.decode64(params[1])
    testHash = OpenSSL::PKCS5::pbkdf2_hmac_sha1(password, self.salt, 1000, pbkdf2.length)

    return pbkdf2 == testHash
  end

  def email_activate
    self.email_confirmed = true
    self.confirm_token = nil
    save!(:validate => false)
  end

  def set_confirmation_token
    self.confirm_token = SecureRandom.urlsafe_base64.to_s
    save!(:validate => false)
  end

  def reset_password!(password)
    self.set_password(password)
    self.confirm_token = nil
    save!(:validate => false)
  end

  private
  def confirmation_token
    if self.confirm_token.blank?
      self.confirm_token = SecureRandom.urlsafe_base64.to_s
    end
  end
end
