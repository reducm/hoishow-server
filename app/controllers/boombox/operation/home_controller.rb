# encoding: utf-8
class Boombox::Operation::HomeController < Boombox::Operation::ApplicationController
  before_filter :check_login!

  def index
  end
end
