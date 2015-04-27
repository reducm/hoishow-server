class DatetimepickerInput < SimpleForm::Inputs::Base
  def input(wrapper_options) 
    @builder.text_field(attribute_name, input_html_options.merge(wrapper_options))
  end 
end


