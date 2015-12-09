# encoding: utf-8
class Boombox::V1::ApplicationController < ApplicationController
  before_filter :set_logger!, :api_verify!
  skip_before_filter :verify_authenticity_token
  attr_reader :logger
  rescue_from StandardError, with: :log_error
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found_respond

  protected
  def render_404(msg)
    render json: { errors: msg }, status: 404
  end

  def error_respond(msg)
    render json: { errors: msg }, status: 403
  end

  def unauth_respond(msg)
    render json: { errors: msg }, status: 401
  end

  def valid_sign?
    options = params.except(:action, :controller, :format, :avatar)
    @auth.boombox_valid_sign?(options)
  end

  def api_verify!
    # valid sign
    return true if Rails.env == 'development'
    @auth = Rails.cache.fetch("api_auth_#{params[:key]}") do
      ApiAuth.where(key: params[:key]).first
    end

    if @auth.blank?
      return unauth_respond("Key can not be blank")
    elsif !valid_sign?
      return unauth_respond("sign error")
    end

    # valid timestamp
    begin
      timestamp = params[:timestamp].to_i
      t = Time.at(timestamp)
      if Time.now - t > 10.minutes
        return error_respond("api request time limit 10 min")
      end
    rescue
      return error_respond("timestamp error")
    end
  end

  def get_user
    @user = User.find_by_api_token(params[:api_token])
  end

  #无用户参数信息时会直接返回403错误
  def check_login!
    #这里的错误返回信息会影响app判断,不能随便改
    return error_respond("no api_token!") if params[:api_token].blank?

    @user = User.find_by_api_token(params[:api_token])

    return error_respond("api_token wrong") if @user.blank?

    if verify_block?(@user)
      render json: {errors: "你的账户由于安全原因暂时不能登录，如有疑问请致电400-880-5380"}, status: 406
      return false
    end

    @user
  end

  def set_logger!
    @logger ||= Logger.new(File.join(Rails.root, 'log', "boombox-#{Rails.env}.log"), 'weekly')
    @logger.info("\nStarted #{request.request_method} #{request.fullpath} for " \
      "#{request.env['HTTP_HOST']} at #{Time.now}\n Params: #{params.to_hash}\n\n")
  end

  def log_error(e)
    # transaction log to show
    logger.error(e)
    render json: {errors: '服务器开小差'}, status: 500
  end
end
