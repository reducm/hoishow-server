# coding: utf-8
module FetchBeatportData
  module BeatportLogger
    def logger_file
      Rails.root.join('log', 'beatport.log')
    end

    def beatport_logger
      @logger ||= Yell.new do |l|
        l.adapter :datefile, logger_file, level: 'lte.error', keep: 5
      end
    end
  end
end
