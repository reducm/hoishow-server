# encoding: utf-8
class Boombox::Operation::ApplicationController < ApplicationController
  layout "boombox_operation"

  before_filter :check_login!

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to boombox_operation_root_url, :alert => exception.message
  end

  def subject_relate_tag(tag_names = [], subject = nil, need_del_tag = true)
    if subject && tag_names.present?
      tags_array = []
      tag_names.split(",").each do |name|
        downcase_name = name.gsub(/\s/, "").downcase
        tags_array << BoomTag.where(name: name, lower_string: downcase_name).first_or_create!
      end
      tags_array.each do |tag|
        tag.tag_subject_relations.where(subject_id: subject.id, subject_type: subject.class.name).first_or_create!
      end
      #对艺术家来说，只需要创建，关联标签，不需要删除标签
      if need_del_tag
        subject.tag_subject_relations.where.not(boom_tag_id: tags_array.map{|tag| tag.id}).delete_all
      end
    end
  end

  def get_subject_tags(subject = nil)
    if subject
      subject.boom_tags.any? ? subject.boom_tags.pluck(:id) : []
    else
      []
    end
  end

  protected

  def check_login!
    unless current_admin
      session[:request_page] = request.original_url
      flash[:notice] = "Please login"
      redirect_to boombox_operation_signin_url
    end
  end

  def current_admin
    @current_admin ||= BoomAdmin.find_by_id(session[:admin_id]) if session[:admin_id]
  end

  def current_ability
    @current_ability ||= ::Ability.new(current_admin)
  end

  helper_method :current_admin
end
