# encoding: utf-8
class Operation::ApplicationController < ApplicationController
  layout "operation"

  before_filter :check_login!
  protected
  # 组装给订单列表用的过滤条件
  # 用于订单列表页和演出详情页
  def get_orders_filters
    # 供订单table view过滤
    @status_filter = status_filter
    # {"hoishow"=>0, "bike_ticket"=>1}
    @channel_filter = Order.channels
    @buy_origin_filter = buy_origin_filter
    @show_filter = show_filter
    @mode_filter = mode_filter
  end
  # {"已出票"=>2, "未支付"=>0, ...}
  def status_filter
    hash = {}
    Order.select(:status).distinct.order(:status).each do |order|
      hash[order.tran("status")] = order[:status]
    end
    hash
  end
  def mode_filter
    hash = {}
    Show.sources.each do |k, v|
      hash[Show.human_attribute_name("source.#{k}")] = v
    end
    hash
  end
  # {"ios"=>"ios", "android"=>"android"}
  def buy_origin_filter
    hash = {}
    Order.select(:buy_origin).distinct.each do |order|
      hash[order[:buy_origin]] = order[:buy_origin]
    end
    hash
  end
  # {"Coldplay全球巡回演唱会北京站"=>1}
  def show_filter
    hash = {}
    Order.select(:show_id, :show_name).distinct.each do |order|
      hash[order[:show_name]] = order[:show_id]
    end
    hash
  end

  def check_login!
    unless current_admin
      session[:request_page] = request.original_url
      flash[:notice] = "Please login"
      redirect_to operation_signin_url
    end
  end

  def current_admin
    @current_admin ||= Admin.find_by_id(session[:admin_id]) if session[:admin_id]
  end

  def current_ability
    @current_ability ||= ::Ability.new(current_admin)
  end

  helper_method :current_admin
end
