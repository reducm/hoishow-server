class Collaborator < ActiveRecord::Base
  include Searchable

  has_many :user_follow_collaborators
  has_many :followers, through: :user_follow_collaborators, source: :user

  has_many :collaborator_activity_relations
  has_many :activities, through: :collaborator_activity_relations, source: :boom_activity

  has_many :boom_albums
  has_many :boom_topics
  has_many :boom_playlists, -> { where creator_type: BoomPlaylist::CREATOR_COLLABORATOR }, foreign_key: 'creator_id'
  has_many :boom_tracks, -> { where creator_type: BoomTrack::CREATOR_COLLABORATOR }, foreign_key: 'creator_id'

  has_many :tag_subject_relations, as: :subject
  has_many :boom_tags, through: :tag_subject_relations, as: :subject,
            after_add: [ lambda { |a,c| a.__elasticsearch__.index_document } ],
            after_remove: [ lambda { |a,c| a.__elasticsearch__.index_document } ]

  mount_uploader :cover, ImageUploader
  mount_uploader :avatar, ImageUploader
  after_create :set_removed_and_is_top
  scope :verified, -> { where(verified: true, removed: false).order('is_top') }

  validates :identity, presence: {message: "身份不能为空"}
  validates :nickname, presence: {message: "昵称不能为空"}
  validates :name, presence: {message: "真实姓名不能为空"}
  validates :sex, presence: {message: "性别不能为空"}
  validates :birth, presence: {message: "生日不能为空"}
  validates :email, presence: {message: "性别不能为空"}
  # 艺人简介字数上限100字
  validates :description, length: { maximum: 200}

  # 身份
  enum identity: {
    dj: 0, # DJ
    producer: 1, # 制作人
    party_planer: 2, # 派对搞手
  }

  enum sex: {
    male: 0,
    female: 1
  }

  mapping do
    indexes :name, analyzer: 'snowball'
    indexes :boom_tags, type: 'nested' do
      indexes :name, analyzer: 'snowball'
    end
  end

  def as_indexed_json(options={})
    as_json(
      only: :name,
      include: { boom_tags: {only: :name} }
    )
  end

  def nickname_changeable?(collaborator, new_nickname)
    if collaborator.nickname != new_nickname && (Time.now - collaborator.updated_at) / 24 / 60 / 60 <= 30
      false
    else
      true
    end
  end

  def is_top_cn
    if is_top?
      "推荐"
    else
      ""
    end
  end

  def verified_cn
    if verified?
      "已审核"
    else
      "审核中"
    end
  end

  def is_followed(user_id)
    user_id.in?(user_follow_collaborators.pluck(:user_id))
  end

  def followed_count
    followers.count
  end

  private
  def set_removed_and_is_top
    self.update(removed: 0, is_top: 0)
  end
end
