class BoomTag < ActiveRecord::Base
  has_many :tag_subject_relations

  scope :hot_tags, -> { where is_hot: true }

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
end
