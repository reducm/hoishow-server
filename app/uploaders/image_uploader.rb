# encoding: utf-8
IMAGE_UPLOADER_ALLOW_IMAGE_VERSION_NAMES = %(avatar photo 320 640 800 poster cover radio playlist image blur sportsposter)
class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  if Rails.env.production? || Rails.env.boombox? || Rails.env.staging?
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

  # 覆盖 url 方法以适应“图片空间”的缩略图命名
  def url(version_name = "")
    @url ||= super({})
    version_name = version_name.to_s
    return @url if version_name.blank?
    unless version_name.in?(IMAGE_UPLOADER_ALLOW_IMAGE_VERSION_NAMES)
      # 故意在调用了一个没有定义的“缩略图版本名称”的时候抛出异常，以便开发的时候能及时看到调错了
      raise "ImageUploader version_name:#{version_name} not allow."
    end
    [@url,version_name].join("!") # 我这里在图片空间里面选用 ! 作为“间隔标志符”
  end

  def extension_white_list
    %w(jpg jpeg gif png bmp pdf)
  end

  def md5
    chunk = model.send(mounted_as)
    @md5 ||= Digest::MD5.hexdigest(chunk.read.to_s)
  end

  # by 华哥
  # Override the filename of the uploaded files:
  def filename
    if super.present?
      # current_path 是 Carrierwave 上传过程临时创建的一个文件，有时间标记
      # 例如: /Users/jason/work/ruby-china/public/uploads/tmp/20131105-1057-46664-5614/_____2013-11-05___10.37.50.png
      @name ||= Digest::MD5.hexdigest(current_path)
      "#{@name}#{File.extname(super)}"
    end
  end
  #def filename
    #@name ||= "#{md5}#{File.extname(super)}" if super
  #end
end
