#encoding: UTF-8
class Api::V1::AdminsController < Api::V1::ApplicationController
  skip_before_filter :api_verify

  def sign_in 
    @admin = Admin.where(name: params[:name]).first
    if @admin && @admin.password_valid?(params[:password])
      @admin.sign_in_api
    else
      return error_json "账户或密码错误"
    end
  end
end
