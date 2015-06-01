# encoding: utf-8
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  protected
  def verify_phone?(phone)
    phone =~ /^0?(13[0-9]|15[012356789]|18[0-9]|17[0-9]|14[57])[0-9]{8}$/
  end

  def verify_email?(email)
    email =~ /^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i
  end

  def verify_block?(user)
    user.is_block
  end
end
