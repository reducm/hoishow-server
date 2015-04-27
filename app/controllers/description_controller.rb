class DescriptionController < ApplicationController
  def show
    if !params[:subject_type].in?(%W( Banner Star Show Concert ))
      render text: "not allow", status: 403
      return false
    end
    @subject = Object::const_get(params[ :subject_type ]).where(id: params[:subject_id]).first
    @description = @subject.description
  end
end
