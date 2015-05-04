class Admin < ActiveRecord::Base
  validates :admin_type, presence: true
  validates :name, presence: true, uniqueness: true

  has_many :banners

  enum admin_type: {
    admin: 0,
    operator: 1
  }

  def type_cn
    case admin_type
    when 0
      '管理员'
    when 1
      '运营'
    end
  end

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
end
