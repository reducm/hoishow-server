# encoding: utf-8
include QueryExpress

class ExpressDetailController < ApplicationController
  layout false

  def show
    data = get_express_info(params[:code])["result"]
    if data.any?
      @result = data
    end
  end
end
