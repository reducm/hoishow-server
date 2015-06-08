# encoding: utf-8

class VideoUploader < CarrierWave::Uploader::Base
  # Filenames and unicode chars
  if Rails.env.production? || Rails.env.staging?
    storage :upyun
  else
    storage :file
  end

  ImgUpyunSetting = UpyunSetting["hoishow-file"]

  self.upyun_username = ImgUpyunSetting["upyun_username"]
  self.upyun_password = ImgUpyunSetting["upyun_password"]
  self.upyun_bucket = ImgUpyunSetting["upyun_bucket"]
  self.upyun_bucket_domain = ImgUpyunSetting["upyun_bucket_domain"]

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}"
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
