class Seat < ActiveRecord::Base
  belongs_to :show
  belongs_to :area

  enum status: {
    avaliable: 0,  #可选
    locked: 1, #不可选
    unused: 2 #空白
  }
end
