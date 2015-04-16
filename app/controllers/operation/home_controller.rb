class Operation::HomeController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource

  def index
  end
end
