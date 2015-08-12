# encoding: utf-8
class Api::V1::StartupController < Api::V1::ApplicationController
  def index
    @startup = Startup.where(is_display: 1).first
  end
end
