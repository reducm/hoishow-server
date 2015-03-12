class ShowAreaRelation < ActiveRecord::Base
  belongs_to :show
  belongs_to :area

  validates :show, presence: {message: "Area不能为空"}
  validates :area, presence: {message: "Show不能为空"}
end
