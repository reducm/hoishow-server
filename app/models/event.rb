class Event < ActiveRecord::Base
  default_scope {order('show_time')}
  has_many :areas, dependent: :destroy
  belongs_to :show

  scope :verified, -> { where('events.show_time > ? AND events.is_display = ?', Time.now, true)}

  mount_uploader :stadium_map, ImageUploader
  mount_uploader :coordinate_map, ImageUploader

  def stadium_map_url
    if show.source == 'yongle'
      show.stadium_map_url
    else
      super
    end
  end

  def is_display_cn
    is_display ? '显示' : '不显示'
  end

  def self.hide_finished_event
    events = Event.eager_load(:areas).where('events.show_time is not null and events.show_time < ? or areas.event_id is null', Time.now)
    events.update_all(is_display: false)
  end
end
