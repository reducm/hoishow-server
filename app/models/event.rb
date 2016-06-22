class Event < ActiveRecord::Base
  default_scope {order('show_time')}
  has_many :areas, dependent: :destroy
  belongs_to :show, touch: true

  validates :show_time, presence: true

  scope :verified, -> { where('events.show_time > ? AND events.is_display = ?', Time.now, true)}
  scope :is_display, -> { where(is_display: true)}

  mount_uploader :stadium_map, ImageUploader
  mount_uploader :coordinate_map, ImageUploader

  before_save :update_description_time

  def stadium_map_url
    if show.source == 'yongle' && show.stadium_map_url && stadium_map.url.nil?
      show.stadium_map_url
    else
      super
    end
  end

  def is_display_cn
    is_display ? '显示' : '隐藏'
  end

  private
  def update_description_time
    wday = show_time.wday
    time = if is_multi_day
             "#{show_time.strftime('%m月%d日')} - #{end_time.strftime('%m月%d日')}"
           else
             "#{I18n.t('date.abbr_day_names')[wday]} #{show_time.strftime('%m月%d日 %H:%M')}"
           end
    self.description_time = time
  end
end
