# encoding: utf-8
class Boombox::Dj::ApplicationController < ApplicationController
  layout "boombox_dj"

  before_filter :check_login!

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to boombox_dj_root_url, :alert => exception.message
  end

  protected

  def subject_relate_tag(tag_names = [], subject = nil, need_del_tag = true)
    if subject && tag_names.present?
      tags_array = []
      tag_names.split(",").each do |name|
        downcase_name = name.gsub(/\s/, "").downcase
        tag = BoomTag.where(lower_string: downcase_name).first_or_create(name: name)
        tags_array.push(tag) if tag
      end
      tags_array.each do |tag|
        tag.tag_subject_relations.where(subject_id: subject.id, subject_type: subject.class.name).first_or_create!
      end
      #对艺术家来说，只需要创建，关联标签，不需要删除标签

      subject.tag_subject_relations.where.not(boom_tag_id: tags_array.map{|tag| tag.id}).delete_all if need_del_tag
    end
  end

  def get_subject_tags(subject = nil)
    subject.present? ? subject.boom_tags.pluck(:id) : []
  end

  def get_all_tag_names
    BoomTag.valid_tags.pluck(:name)
  end

  def check_login!
    unless current_admin
      session[:dj_request_page] = request.original_url
      flash[:warning] = "Please login"
      redirect_to boombox_dj_signin_url
    end
  end

  def current_admin
    @current_admin ||= BoomAdmin.where(id: session[:dj_admin_id], admin_type: BoomAdmin.admin_types[:dj]).first if session[:dj_admin_id]
  end

  # 登陆后得到该dj  
  def current_collaborator
    Collaborator.where(boom_admin_id: current_admin.id).first 
  end

  def current_ability
    @current_ability ||= ::Ability.new(current_admin)
  end

  ## 新回复
  #def unread_comments_count
  #end

  helper_method :current_admin
  helper_method :current_collaborator
end
