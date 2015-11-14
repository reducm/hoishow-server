# 参考k总的模版
# https://raw.githubusercontent.com/elastic/elasticsearch-rails/master/elasticsearch-rails/lib/rails/templates/searchable.rb
module BoomCommentSearchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    # Set up callbacks for updating the index on model changes
    after_commit lambda { Indexer.perform_async(:index,  self.class.to_s, self.id) }, on: :create
    after_commit lambda { Indexer.perform_async(:update, self.class.to_s, self.id) }, on: :update
    after_commit lambda { Indexer.perform_async(:delete, self.class.to_s, self.id) }, on: :destroy
    after_touch  lambda { Indexer.perform_async(:update, self.class.to_s, self.id) }

    # Set up index configuration and mapping
    settings index: { number_of_shards: 1, number_of_replicas: 0 } do
      mapping do
        indexes :content, type: 'multi_field' do
          indexes :content,   analyzer: 'snowball'
          indexes :tokenized, analyzer: 'simple'
        end

        indexes :created_at, type: 'date'
      end
    end

    # Search in content field for `query`
    #
    # @param query [String] The user query
    # @return [Elasticsearch::Model::Response::Response]
    def self.search(query, options={})
      @search_definition = {
        query: {},
      }

      unless query.blank?
        @search_definition[:query] = {
          bool: {
            should: [
              { multi_match: {
                  query: query,
                  fields: ['content'],
                  operator: 'and'
                }
              }
            ]
          }
        }
      else
        # 关键词为空时返回全部
        @search_definition[:query] = { match_all: {} }
      end
      @search_definition[:sort]  = { created_at: 'desc' }

      __elasticsearch__.search(@search_definition)
    end
  end
end
