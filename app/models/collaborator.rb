class Collaborator < ActiveRecord::Base
  include Searchable

  attr_reader :collaborator_tag_names

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

  mount_uploader :cover, BoomImageUploader
  mount_uploader :avatar, BoomImageUploader

  before_create :set_nickname_updated_at, :set_removed_and_is_top
  before_update :set_nickname_updated_at, if: :nickname_has_changed?

  scope :verified, -> { where(verified: true, removed: false).order('is_top desc, created_at desc') }

  validates :identity, presence: {message: "身份不能为空"}
  validates :nickname, presence: {message: "昵称不能为空"}, uniqueness: {message: "昵称已被使用"}
  validate :nickname_changeable, on: :update, if: :nickname_has_changed?
  validates :name, presence: {message: "真实姓名不能为空"}
  validates :sex, presence: {message: "性别不能为空"}
  validates :birth, presence: {message: "生日不能为空"}
  validates :email, presence: {message: "邮箱不能为空"}
  # 艺人简介字数上限100字
  validates :description, length: { maximum: 1000}

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

  mapping dynamic: 'false' do
    indexes :display_name, analyzer: 'snowball'
    indexes :boom_tags, type: 'nested' do
      indexes :name, analyzer: 'snowball'
    end
  end

  def as_indexed_json(options={})
    as_json(
      methods: [:display_name], only: [:display_name],
      include: { boom_tags: {only: :name} }
    )
  end

  def is_top_cn
    if is_top?
      "是"
    else
      "否"
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

  def nickname_changeable
    errors.add(:nickname_updated_at, "昵称一个月只能改一次") unless (Time.now - self.nickname_updated_at) / 60 / 60 / 24 > 30
  end

  def nickname_has_changed?
    nickname_changed?
  end

  def display_name
    nickname || name
  end

  def tag_for_collaborator(tag)
    tag_subject_relations.where(boom_tag_id: tag.id).first_or_create!
  end

  def track_count
    boom_tracks.count
  end

  def collaborator_tag_names
    boom_tags.pluck(:name).join(",")
  end

  private
  def set_removed_and_is_top
    self.removed = 0
    self.is_top = 0
  end

  def set_nickname_updated_at
    self.nickname_updated_at = Time.now
  end
end
