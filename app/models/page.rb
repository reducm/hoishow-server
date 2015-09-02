class Page < ActiveRecord::Base
  ALL_PAGE = %W(mobile_about terms)

  validates :title, inclusion: {in: ALL_PAGE}, uniqueness: true
end
