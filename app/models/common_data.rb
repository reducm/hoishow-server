class CommonData < ActiveRecord::Base
  self.table_name = 'common_data'

  validates :common_key, :common_value, :remark, presence: true
  validates :common_key, :common_value, uniqueness: true

  class << self
    def get_value(key)
      where(common_key: key).first.try(:common_value)
    end
  end
end
