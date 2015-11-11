# encoding: utf-8
class Boombox::Operation::BoomTagsController < Boombox::Operation::ApplicationController
  before_filter :check_login!

  def index
    @boom_tags = BoomTag.valid_tags.page(params[:page]).order("created_at desc")
  end

  def create
    if params[:tag_name].present?
      tag_name = params[:tag_name]
      @boom_tag = BoomTag.new(name: tag_name)
      @boom_tag.lower_string = tag_name.gsub(/\s/, "").downcase
      if @boom_tag.save!
        flash[:notice] = '创建标签成功'
      else
        flash[:alert] = '标签名称重复，创建标签失败'
      end
    else
      flash[:alert] = '标签名称不能为空'
    end
    redirect_to boombox_operation_boom_tags_url
  end

  def destroy
    @boom_tag = BoomTag.find(params[:id])
    @boom_tag.destroy!
    redirect_to action: :index
  end

  def change_is_top
    @boom_tag = BoomTag.find(params[:id])
    if @boom_tag.is_hot
      @boom_tag.update(is_hot: false)
      flash[:notice] = "取消推荐成功"
    else
      @boom_tag.update(is_hot: true)
      flash[:notice] = "更新推荐成功"
    end
    redirect_to boombox_operation_boom_tags_url
  end

  def search
    if params[:q].present?
      query_str = "name like '%#{params[:q]}%'"
      if params[:select_options] == "1"
        query_str = query_str + " and is_hot = true"
      end
      @boom_tags = BoomTag.valid_tags.where(query_str).page(params[:page]).order("created_at desc")
    else
      if params[:select_options] == "1"
        @boom_tags = BoomTag.valid_tags.where(is_hot:true).page(params[:page]).order("created_at desc")
      else
        @boom_tags = BoomTag.valid_tags.page(params[:page]).order("created_at desc")
      end
    end
    render :index
  end

end
