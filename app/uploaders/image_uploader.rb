# encoding: utf-8
#MAGE_UPLOADER_ALLOW_IMAGE_VERSION_NAMES = %(320 640 800)
IMAGE_UPLOADER_ALLOW_IMAGE_VERSION_NAMES = %(avatar 120x160 224x292 300x423 320 640 800)
class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  if Rails.env.production? || Rails.env.staging?
    storage :upyun
  else
    storage :file
  end

  ImgUpyunSetting = UpyunSetting["hoishow-img"]

  self.upyun_username = ImgUpyunSetting["upyun_username"]
  self.upyun_password = ImgUpyunSetting["upyun_password"]
  self.upyun_bucket = ImgUpyunSetting["upyun_bucket"]
  self.upyun_bucket_domain = ImgUpyunSetting["upyun_bucket_domain"]

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}"
  end

  #def default_url
  #  # 搞一个大一点的默认图片取名 blank.png 用 FTP 传入图片空间，用于作为默认图片
  #  # 由于有自动的缩略图处理，小图也不成问题
  #  # Setting.upload_url 这个是你的图片空间 URL
  #  "#{UpyunSetting["upyun_upload_url"]}/default.gif#{version_name}"
  #end

  # 覆盖 url 方法以适应“图片空间”的缩略图命名
  def url(version_name = "")
    @url ||= super({})
    version_name = version_name.to_s
    return @url if version_name.blank?
    if not version_name.in?(image_version_name)
      # 故意在调用了一个没有定义的“缩略图版本名称”的时候抛出异常，以便开发的时候能及时看到调错了
      raise "ImageUploader version_name:#{version_name} not allow."
    end
    [@url,version_name].join("!") # 我这里在图片空间里面选用 ! 作为“间隔标志符”
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def filename
    if super.present?
      @name ||="#{Digest::MD5.hexdigest(Time.now.to_i.to_s + original_filename)}.#{file.extension.downcase}" if original_filename
    end
  end

  private
  def image_version_name
    %(avatar 120x160 224x292 300x423 320 640 800)
  end
end
