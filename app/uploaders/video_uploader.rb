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

  def md5
    chunk = model.send(mounted_as)
    @md5 ||= Digest::MD5.hexdigest(chunk.read.to_s)
  end

  def filename
    @name ||= "#{md5}#{File.extname(super)}" if super
  end

  def extension_white_list
    %w(mp4)
  end
end
