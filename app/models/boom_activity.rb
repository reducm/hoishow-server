class BoomActivity < ActiveRecord::Base
  include Searchable

  belongs_to :boom_location
  belongs_to :boom_admin

  has_many :collaborator_activity_relations
  has_many :collaborators, through: :collaborator_activity_relations, source: :collaborator

  has_many :activity_track_relations
  has_many :tracks, through: :activity_track_relations, source: :boom_track

  has_many :tag_subject_relations, as: :subject
  has_many :boom_tags, through: :tag_subject_relations, as: :subject,
            after_add: [ lambda { |a,c| a.__elasticsearch__.index_document } ],
            after_remove: [ lambda { |a,c| a.__elasticsearch__.index_document } ]

  enum mode: {
    show: 0,
    activity: 1
  }

  after_create :set_activity_param

  scope :is_display, ->{ where(is_display: true, removed: false).order('is_top')}

  mount_uploader :cover, ImageUploader

  paginates_per 10

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

  def location_name
    boom_location.name if boom_location
  end

  def is_display_cn
    if is_display
      "显示"
    else
      "不显示"
    end
  end

  def is_hot_cn
    if is_hot
      "正在推荐"
    else
      "没有推荐"
    end
  end

  def tag_for_activity(tag)
    tag_subject_relations.where(boom_tag_id: tag.id).first_or_create!
  end

  def relate_collaborator(collaborator)
    collaborator_activity_relations.where(collaborator_id: collaborator.id).first_or_create!
  end

  private
  def set_activity_param
    activity_param = {removed: 0, is_top: 0, is_display: 0, is_hot: 0}
    activity_param.delete(:is_hot) if is_hot
    activity_param.delete(:is_display) if is_display

    self.update(activity_param)
  end
end
