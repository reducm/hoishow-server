class BoomAdminMailer < ApplicationMailer
  default :from => "dc-notify@bestapp.us"

  # dj注册后发验证邮件
  def registration_confirmation(dj)
    @dj = dj
    mail(:to => "<#{dj.email}>", :subject => "播霸邮箱验证")
  end

  def forget_password(dj)
    @dj = dj
    mail(:to => "<#{dj.email}>", :subject => "播霸密码重置")
  end

  def new_collaborator_notify(dj)
    @dj = dj
    mail(to: "boombox@bestapp.us", subject: "#{dj.display_name} - 申请加入播霸音乐")
  end
end
