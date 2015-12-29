# encoding: utf-8
class Boombox::Operation::ApplicationController < ApplicationController
  layout "boombox_operation"

  before_filter :check_login!

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to boombox_operation_root_url, :alert => exception.message
  end

  def subject_relate_tag(tag_ids = [], subject = nil)
    if subject
      tag_ids = tag_ids.split(",")
      BoomTag.where(id: tag_ids).each do |tag|
        tag.tag_subject_relations.where(subject_id: subject.id, subject_type: subject.class.name).first_or_create!
      end
      subject.tag_subject_relations.where.not(boom_tag_id: tag_ids).delete_all
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
