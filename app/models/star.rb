class Star < ActiveRecord::Base
  #include Searchable
  #searchkick Searchable::WORD_TYPE.map{|k| Hash[k, [:name]] }.inject(&:merge)

  has_many :videos
  has_many :user_follow_stars
  has_many :followers, through: :user_follow_stars, source: :user

  has_many :star_concert_relations
  has_many :concerts, through: :star_concert_relations

  validates :name, presence: {message: "姓名不能为空"}

  has_many :topics, :class_name => "Topic", :foreign_key => 'subject_id'
  #has_many :comments, :class_name => "Comment", :foreign_key => 'subject_id'

  mount_uploader :avatar, AvatarUploader 

  paginates_per 20

  def hoi_concert(concert)
    star_concert_relations.where(concert: concert).first_or_create!
  end

  def shows
    concert_ids = concerts.pluck(:id)    
    Show.where(concert_id: concert_ids)
  end

  class << self
    def search(q)
      where("name like ?", "%#{q}%")
    end
  end
end
