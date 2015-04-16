class Operation::OrdersController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource
end
