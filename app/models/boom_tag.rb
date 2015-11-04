class BoomTag < ActiveRecord::Base
  scope :hot_tags, -> { where is_hot: true }
  #取出合集得时候不要忘记过滤
  scope :valid_tags, -> {where removed: false}

  after_create :set_removed_and_is_hot

  validates :subject_type, presence: true

  def collaborators
    query(Collaborator)
  end

  def playlists
    query(BoomPlaylist)
  end

  def activities
    query(BoomActivity)
  end

  def tracks
    query(BoomTrack)
  end

  private
  def query(model)
    model.joins(:tag_subject_relations).where('tag_subject_relations.boom_tag_id = ?', self.id)
  end

  def set_removed_and_is_hot
    self.update(removed: 0, is_hot: 0)
  end
end
