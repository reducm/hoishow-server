# encoding: utf-8
class Boombox::Operation::BoomAdminsController < Boombox::Operation::ApplicationController
  before_filter :check_login!
  before_filter :get_boom_admin, except: [:index, :new, :create]

  def index
    @boom_admins = BoomAdmin.page(params[:page]).order("created_at desc")
  end

  def new
    @boom_admin = BoomAdmin.new
  end

  def create
    @boom_admin = BoomAdmin.new(name: params[:boom_admin_new_username], admin_type: params[:admin_type].to_i)
    @boom_admin.set_password(params[:boom_admin_new_password])
    
    if @boom_admin.save!
      flash[:notice] = '管理员创建成功'
      redirect_to boombox_operation_boom_admins_url
    else
      flash[:alert] = @boom_admin.errors.full_messages
      render :new
    end
  end

  def update
    if params[:boom_admin_edit_pw1].present? && params[:boom_admin_edit_pw1] == params[:boom_admin_edit_pw2]
      @boom_admin.set_password(params[:boom_admin_edit_pw1])
    end
    if @boom_admin.save
      flash[:notice] = '修改成功'
      redirect_to boombox_operation_boom_admins_url
    else
      flash[:alert] = @boom_admin.errors.full_messages
      render :update
    end
  end

  def edit
  end


  private
  def get_boom_admin
    @boom_admin = BoomAdmin.find(params[:id])
  end
end
