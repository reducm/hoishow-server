module Searchable
  extend ActiveSupport::Concern


  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
    WORD_TYPE = [:word_start, :word_middle, :word_end]
    # TODO set fields to index
    # mapping do
    #   ...
    # end
    after_commit :class_reindex
  end

  module ClassMethods
    def wrap_search(q)
      search(q, fields: WORD_TYPE.map{|word_key| {name: word_key}}).to_a
    end
  end

  def class_reindex
    self.class.reindex
  end
end
