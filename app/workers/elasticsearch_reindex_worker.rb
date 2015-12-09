class ElasticsearchReindexWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'elasticsearch', retry: false

  def perform(operation, klass, record_id, options={})
    logger.debug [operation, "#{klass}##{record_id} #{options.inspect}"]

    klass.constantize.import
  end
end
