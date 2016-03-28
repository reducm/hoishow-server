# coding: utf-8
module ViagogoDataToHoishow
  module ViagogoLogger
    def logger_file
      Rails.root.join('log', 'viagogo.log')
    end

    def viagogo_logger
      @logger ||= Yell.new do |l|
        l.adapter :datefile, logger_file, level: 'lte.error', keep: 5
      end
    end
  end
end
