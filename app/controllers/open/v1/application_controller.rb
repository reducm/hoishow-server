# encoding: utf-8
class Open::V1::ApplicationController < ApplicationController
  before_filter :set_logger!, :find_auth!, :api_verify!
  skip_before_filter :verify_authenticity_token
  attr_reader :logger
  rescue_from StandardError, with: :log_error
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found_respond

  protected
  def show_auth!
    @show = Show.find(params[:show_id])
  end

  def area_auth!
    show_auth!
    @area = @show.areas.find(params[:area_id])
  end

  def not_found_respond
    render json: { result_code: 2001, message: "找不到该数据" }, status: 404
  end

  def error_respond(code, msg)
    render json: { result_code: code, message: msg }, status: 403
  end

  def unauth_respond(code, msg)
    render json: { result_code: code, message: msg }, status: 401
  end

  #文档中的必需参数
  def auth_params
    params.except('format', 'action', 'controller', 'out_id')
  end

  def find_auth!
    return true if Rails.env.development?
    @auth = Rails.cache.fetch("api_auth_#{params[:api_key]}") do
      ApiAuth.where(key: params[:api_key]).first
    end

    unless @auth
      render json: { result_code: 1001, message: "商户信息不存在" }, status: 403
    end
  end

  def api_verify!
    return true if Rails.env.development?

    code, msg = @auth.open_api_auth(auth_params)

    unless code == 0
      unauth_respond(code, msg)
    end
  end

  def set_logger!
    @logger ||= Logger.new(File.join(Rails.root, 'log', 'open_api.log'), 'weekly')
    @logger.info("\nStarted #{request.request_method} #{request.fullpath} for " \
      "#{request.env['HTTP_HOST']} at #{Time.now}\n Params: #{params.to_hash}\n\n")
  end

  def log_error(e)
    # transaction log to show
    logger.error(e)
    render json: {result_code: 5000, message: '服务器挂了'}, status: 500
  end

end
