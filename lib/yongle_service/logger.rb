module YongleService
  module Logger
    def logger_file
      Rails.root.join("log", "yongle.log")
    end

    def error_file
      Rails.root.join("log", "error.log")
    end

    def yongle_logger
      @logger ||= Yell.new do |l|
        l.level = 'gte.info'

        l.adapter :datefile, logger_file, level: 'lte.error', keep: 5
        l.adapter :datefile, error_file, level: 'gte.error', keep:5
      end
    end
  end
end
