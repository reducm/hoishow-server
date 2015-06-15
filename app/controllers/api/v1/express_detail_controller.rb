# encoding: utf-8
class Api::V1::ExpressDetailController < Api::V1::ApplicationController
  skip_before_filter :api_verify

  def index
    if params[:code]
      render json: {url: express_detail_url(code: params[:code])}
    else
      error_json("传递参数出现不匹配")
    end
  end
end
