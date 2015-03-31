module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    # TODO set fields to index
    # mapping do
    #   ...
    # end
  end

  module ClassMethods
    def wrap_search(query)
      search_body = {
        multi_match: {
          query: query,
          fields: ["name"]
        }
      }
      search(query: search_body).records
    end
  end
end
