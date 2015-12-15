require 'rails_helper'

RSpec.describe Boombox::Dj::CollaboratorsController, :type => :controller do
  describe 'POST #create' do
    before :each do
      @boom_admin = create :boom_admin
      @boom_admin.email_activate
      session[:boom_admin_id] = @boom_admin.id
    end

    context "with valid attributes" do
      let(:collaborator_attributes) { build(:collaborator).attributes.merge(identity: 'dj', sex: 'male', boom_admin_id: @boom_admin.id)  }

      it "save the new collaborator in the database" do
        expect{
          post :create, collaborator: collaborator_attributes
        }.to change(Collaborator, :count).by(1)
      end

      it "redirect_to signup_finished page" do 
        post :create, collaborator: collaborator_attributes
        expect(response).to redirect_to boombox_dj_signup_finished_url(collaborator_id: assigns[:collaborator].id)
      end 
    end
  end
end
