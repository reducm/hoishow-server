class Page < ActiveRecord::Base
  MOBILE_ABOUT = 'mobile_about'
  TERMS = 'terms'
  ALL_PAGE = [MOBILE_ABOUT, TERMS]

  validates :title, inclusion: {in: ALL_PAGE}, uniqueness: true
end
