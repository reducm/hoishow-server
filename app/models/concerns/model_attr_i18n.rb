module ModelAttrI18n
  extend ActiveSupport::Concern

  def tran(attr_name)
    # use human_attribute_name method
    self.class.human_attribute_name("#{attr_name}.#{self.send "#{attr_name}"}")
  end

  # TranMethods.map do |tm|
  #   define_method("#{tm}_cn") { tran("#{tm}") }
  # end
end
