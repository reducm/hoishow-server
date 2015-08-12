# encoding: utf-8
include QueryExpress

class ExpressDetailController < ApplicationController
  layout 'mobile'

  def show
    @result = get_express_info(params[:code])["result"]
  end
end
