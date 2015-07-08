class SimditorImageController < ApplicationController
  before_filter :set_pasted_pic

  def upload
    simditor_img = SimditorImage.new
    simditor_img.image = params['upload_file']
    if simditor_img.save!
      render json: {
        success: true,
        msg: '',
        file_path: simditor_img.image_url
      }
    else
      render json: {
        success: false,
        msg: 'Uploading Error..'
      }
    end
  end

  private

  def set_pasted_pic
    image_type = params['upload_file'].content_type.match(/image\/(\w*)/)[1]
    params['upload_file'].original_filename = 'simditor' + Time.now.to_s + rand(1000).to_s if params['upload_file'].original_filename == 'blob'
    params['upload_file'].original_filename += ".#{image_type}"
  end
end
