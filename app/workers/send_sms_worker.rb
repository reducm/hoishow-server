class SendSmsWorker
  include Sidekiq::Worker
  def perform(mobile, content)
    ChinaSMS.to(mobile, content)
  end
end
