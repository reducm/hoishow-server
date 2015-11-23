class ConvertAudioWorker
  include Sidekiq::Worker
  include ConvertAudio
  sidekiq_options queue: 'convert_audio', retry: false

  def perform(url)
    ConvertAudio::Service.convert(url)
  end
end
