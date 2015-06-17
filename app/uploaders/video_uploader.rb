# encoding: utf-8

class VideoUploader < CarrierWave::Uploader::Base
  # Filenames and unicode chars
  if Rails.env.production? || Rails.env.staging?
    storage :upyun
  else
    storage :file
  end

  FileUpyunSetting = UpyunSetting['hoishow-file']

  self.upyun_username = FileUpyunSetting['upyun_username']
  self.upyun_password = FileUpyunSetting['upyun_password']
  self.upyun_bucket = FileUpyunSetting['upyun_bucket']
  self.upyun_bucket_domain = FileUpyunSetting['upyun_bucket_domain']

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def filename
    if super.present?
      @name ||="#{Digest::MD5.hexdigest(Time.now.to_i.to_s + original_filename)}.#{file.extension.downcase}" if original_filename
    end
  end

  def extension_white_list
    %w(mp4)
  end
end
