# coding: utf-8
module Wxpay
  module Logger
    def logger_file
      file = self.name.split("::").map{|name| name.underscore}.join("_") + ".log"
      Rails.root.join("log", file)
    end

    def logger
      @logger ||= begin
                    @logger = ::Logger.new(self.logger_file)
                    @logger.level = 0
                    #@logger.formatter = DancheFormater.new
                    @logger
                  end
    end

    def error_file
      Rails.root.join("log", "error.log")
    end

    def yell_logger
      @logger ||= Yell.new do |l|
        l.level = 'gte.info'

        l.adapter :datefile, logger_file, level: 'lte.error', keep: 5
        l.adapter :datefile, error_file, level: 'gte.error', keep: 5
      end
    end
  end
end
