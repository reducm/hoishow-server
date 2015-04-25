require 'passwordhash'

class Admin < ActiveRecord::Base
  validates :admin_type, presence: true
  validates :name, presence: true, uniqueness: true

  has_many :banners

  def is_admin?
    self.admin_type == 0
  end

  def is_operator?
    self.admin_type == 1
  end

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

  def passwd_valid?(password)
    PasswordHash.validatePassword(password, self.encrypted_password)
  end
end
