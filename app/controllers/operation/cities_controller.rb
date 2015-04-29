class Operation::CitiesController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource

  def index
    @cities = City.order('is_hot desc')
  end
end
