# encoding: utf-8
class Operation::HomeController < Operation::ApplicationController
  before_filter :check_login!

  def index
  end
end
