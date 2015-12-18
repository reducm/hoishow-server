class ElasticsearchReindexWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'elasticsearch', retry: false

  Logger = Sidekiq.logger.level == Logger::WARN ? Sidekiq.logger : nil
  Client = Elasticsearch::Client.new host: (ENV['ELASTICSEARCH_URL'] || 'http://localhost:9200'), logger: Logger

  def perform(operation, klass, record_id, options={})
    logger.debug [operation, "#{klass}##{record_id} #{options.inspect}"]

    case operation.to_s
      when /index/
        record = klass.constantize.find(record_id)
        record.__elasticsearch__.client = Client
        record.__elasticsearch__.index_document
      when /delete/
        Client.delete index: klass.constantize.index_name, type: klass.constantize.document_type, id: record_id
      else raise ArgumentError, "Unknown operation '#{operation}'"
    end
  end
end
