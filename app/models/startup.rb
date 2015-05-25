class Startup < ActiveRecord::Base
  mount_uploader :pic, ImageUploader
  after_create :set_valid_time

  private
  def set_valid_time
    self.update(valid_time: Time.now + 1.month) if self.valid_time.nil?
  end
end
