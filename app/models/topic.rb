#encoding: UTF-8
class Topic < ActiveRecord::Base
  belongs_to :city
  validates :creator_id, presence: true
  validates :creator_type, presence: true
  validates :subject_type, presence: true
  validates :subject_id, presence: true
  validate :check_city_id
  has_many :comments, :class_name => "Comment", :foreign_key => 'subject_id'


  def subject
     begin
      Object::const_get(subject_type).where(id: subject_id).first 
    rescue 
      Rails.logger.fatal("subject wrong, topic_id: #{ id }, subject_type: #{subject_type}, subject_id: #{subject_id}")
      nil
    end
  end

  def creator
    begin
      Object::const_get(creator_type).where(id: creator_id).first 
    rescue 
      Rails.logger.fatal("subject wrong, topic_id: #{ id }, subject_type: #{subject_type}, subject_id: #{subject_id}")
      nil
    end
  end

  private 
  def check_city_id
    errors[:city_id] << "subject Concert should have city_id!" if subject_type == Concert.name && city_id.blank?
  end
end
