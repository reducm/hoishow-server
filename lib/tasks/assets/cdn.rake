require 'ftp_sync'
namespace :assets do
  desc 'sync assets to cdns'
  task :cdn => :environment do
    ftp = FtpSync.new("v1.ftp.upyun.com", [UpyunSetting['upyun_username'],UpyunSetting['upyun_bucket']].join("/"), UpyunSetting['upyun_password'],true)
    ftp.sync("#{Rails.root}/public/assets/", "/assets")
  end

  desc 'api assts to upyun'
  task :publish_assets => :environment do
    localpath = 'public'

    Dir[File.join localpath, "**{,/*/**}/*"].select{|f| File.file? f}.each do |file|
      p "upload_local_assets_file#{file}"
    end
    # RailsAssetsForUpyun.publish UpyunSetting['upyun_bucket'], UpyunSetting['upyun_username'], UpyunSetting['upyun_password']
  end
end
