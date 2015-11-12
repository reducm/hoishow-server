require 'rails_helper'

RSpec.describe Operation::UsersController, :type => :controller do
  describe 'GET #index' do
    before :each do
      admin = create(:admin, admin_type: 0)
      ability = Ability.new(admin)
      session[:admin_id] = admin.id
    end

    context 'access by authorized operator' do
      it "should be ok" do
        get :index
        expect(response).to render_template :index
      end
    end
  end
end
