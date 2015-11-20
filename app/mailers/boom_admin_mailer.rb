class BoomAdminMailer < ApplicationMailer
  default :from => "dc-notify@bestapp.us"

  # dj注册后发验证邮件
  def registration_confirmation(dj)
    @dj = dj 
    mail(:to => "<#{dj.email}>", :subject => "播霸邮箱验证")
  end
end
