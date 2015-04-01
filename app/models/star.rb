class Star < ActiveRecord::Base
  include Searchable
  searchkick

  has_many :videos
  has_many :user_follow_stars
  has_many :followers, through: :user_follow_stars, source: :user

  has_many :star_concert_relations
  has_many :concerts, through: :star_concert_relations

  validates :name, presence: {message: "姓名不能为空"}

  has_many :comments, :class_name => "Comment", :foreign_key => 'subject_id'

  mount_uploader :avatar, AvatarUploader 

  def hoi_concert(concert)
    star_concert_relations.where(concert: concert).first_or_create!
  end

  def shows
    concert_ids = concerts.pluck(:id)    
    Show.where(concert_id: concert_ids)
  end

  def search_data
    as_json only: [:name]
    {
      name: name,
    }
  end
end
