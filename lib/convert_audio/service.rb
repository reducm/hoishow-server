require 'rest_client'

module ConvertAudio
  module Service
    extend ConvertAudio::Logger
    FILE_SETTING = Rails.env.production? ? UpyunSetting['boombox-file'] : UpyunSetting['hoishow-file']
    API_URLS = {pretreatment: 'http://p0.api.upyun.com/pretreatment', status: 'http://p0.api.upyun.com/status'}
    OPERATOR_NAME = FILE_SETTING['upyun_username']
    OPERATOR_PASSWORD = FILE_SETTING['upyun_password']
    BUCKET_NAME = FILE_SETTING['upyun_bucket']
    NOTIFY_URL = FILE_SETTING['notify_url']

    def self.generate_tasks
      data = [{
          type: 'audio',
          audio_bitrate: 192
        },{
          type: 'audio',
          audio_bitrate: 320
      }]
      Base64.encode64(data.to_json).gsub(/\n/, '')
    end

    def self.convert(file_url)
      data = {
        bucket_name: BUCKET_NAME,
        source: file_url,
        notify_url: NOTIFY_URL,
        tasks: generate_tasks
      }
      query('post', API_URLS[:pretreatment], Sign.md5_sign(OPERATOR_NAME, OPERATOR_PASSWORD, data), data)
    end

    def self.status(task_ids)
      data = {
        bucket_name: BUCKET_NAME,
        task_ids: task_ids
      }
      url = "#{API_URLS[:status]}?#{data.map{|k, v| "#{k.to_s}=#{v}"}.join('&')}"
      query('get', url, Sign.md5_sign(OPERATOR_NAME, OPERATOR_PASSWORD, data))
    end

    def self.query(method, url, sign, options={})
      begin
        upyun_logger.info "Method: #{method}, Url: #{url}, Sign: #{sign}, Options: #{options.inspect}"
        if method == 'get'
          response = RestClient.get url, {Authorization: "UPYUN #{OPERATOR_NAME}:#{sign}"}
        elsif method == 'post'
          response = RestClient.post url, options, {Authorization: "UPYUN #{OPERATOR_NAME}:#{sign}"}
        end
        upyun_logger.info "Result: #{response.inspect}"
        response
      rescue => e
        upyun_logger.error "Error: #{e.inspect}"
        false
      end
    end
  end
end
