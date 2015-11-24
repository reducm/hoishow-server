module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    after_commit lambda { ElasticsearchReindexWorker.perform_async(:index,  self.class, self.id) }, on: :create
    after_commit lambda { ElasticsearchReindexWorker.perform_async(:update, self.class, self.id) }, on: :update

    def self.search(query, options={})
      __elasticsearch__.search(
        {
          query: {
            multi_match: {
              query: query,
              fuzziness: 'auto',
              fields: '_all',
              max_expansions: 10
            }
          }
        }
      )
    end
  end
end
