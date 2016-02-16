# encoding: utf-8
class Boombox::Operation::BoomTagsController < Boombox::Operation::ApplicationController
  def index
    params[:page] ||= 1
    params[:per] ||= 10
    boom_tags = BoomTag.valid_tags

    if params[:is_hot].present?
      boom_tags = boom_tags.where(is_hot: params[:is_hot])
    end

    if params[:q].present?
      boom_tags = boom_tags.where("boom_tags.name like ?", "%#{params[:q]}%")
    end

    @boom_tags = boom_tags.order("created_at desc").page(params[:page]).per(params[:per])

    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    if params[:tag_name].present?
      tag_name = params[:tag_name]
      @boom_tag = BoomTag.new(name: tag_name)
      @boom_tag.lower_string = tag_name.gsub(/\s/, "").downcase
      if @boom_tag.save
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

  def change_is_hot
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
end
