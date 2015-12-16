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
              fields: '_all'
            }
          },
          size: 100 #搜索结果上限100条, 如果有需求扩大必须用es的分页，要不然加载太慢
        }
      )
    end
  end
end
