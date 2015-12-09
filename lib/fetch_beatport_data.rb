require 'fetch_beatport_data/beatport_logger'
require 'fetch_beatport_data/fetch_bp_data'

module FetchBeatportData
  def self.read_data
    File.open("public/temp.json", "r") do |file|
      file.each do |line|
        l = JSON.parse(line)
        p l
      end
    end
  end
end
