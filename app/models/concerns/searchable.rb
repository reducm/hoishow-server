module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    after_commit lambda { ElasticsearchReindexWorker.perform_async(:index,  self.class, self.id) }, on: [:create, :update]
    after_commit lambda { ElasticsearchReindexWorker.perform_async(:delete, self.class, self.id) }, on: :destroy

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
