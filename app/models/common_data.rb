class CommonData < ActiveRecord::Base
  self.table_name = 'common_data'

  validates :common_key, :common_value, :remark, presence: true
  validates :common_key, :common_value, uniqueness: true
end
