class BoomPlaylist < ActiveRecord::Base
  validates :name, presence: true

  enum mode: {
    playlist: 0,
    radio: 1
  }
end
