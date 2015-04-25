require 'passwordhash'

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
    self.encrypted_password = PasswordHash.createHash(password)
  end

  def password_valid?(password)
    PasswordHash.validatePassword(password, self.encrypted_password)
  end
end
