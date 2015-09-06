class Help < ActiveRecord::Base
  include ModelAttrI18n

  validates :description, presence: {message: "内容不能为空"}
  validates :position, uniqueness: true

  before_create :set_position

  private
  def set_position
    self.position = Help.maximum("position").to_i + 1
  end
end
