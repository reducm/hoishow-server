#encoding: UTF-8
class ShowAreaRelation < ActiveRecord::Base
  belongs_to :show
  belongs_to :area

  validates :show, presence: {message: "演出不能为空"}
  validates :area, presence: {message: "区域不能为空"}
  validates_uniqueness_of :show_id, scope: [:area_id]
end
