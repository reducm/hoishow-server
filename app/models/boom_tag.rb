require 'elasticsearch/model'

class BoomTag < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  has_many :tag_subject_relations
  has_many :collaborators, through: :tag_subject_relations, source: :subject, source_type: Collaborator.name
  has_many :playlists, through: :tag_subject_relations, source: :subject, source_type: BoomPlaylist.name
  has_many :activities, through: :tag_subject_relations, source: :subject, source_type: BoomActivity.name
  has_many :tracks, through: :tag_subject_relations, source: :subject, source_type: BoomTrack.name

  scope :hot_tags, -> { where is_hot: true }

  def as_indexed_json(options={})
    as_json(
      only: :name
    )
  end
end

BoomTag.import(force: true)
