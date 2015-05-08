module SpecTestHelper
  def login_admin
    login(:admin)
  end

  def login(admin)
    admin = Admin.where(name: admin.to_s).first if admin.is_a?(Symbol)
    request.session[:admin_id] = admin.id
  end

  def current_admin
    Admin.find(request.session[:admin_id])
  end
end
