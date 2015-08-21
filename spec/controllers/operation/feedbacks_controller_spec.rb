require 'rails_helper'

RSpec.describe Operation::FeedbacksController, :type => :controller do
  render_views
  before('each') do
    admin = create :admin
    login(admin)
    100.times {create :feedback}
  end

  context '#index' do
    it 'should list 10 per page' do
      get :index
      expect(assigns(:feedbacks).size).to eq 10
      expect(response).to render_template :index
    end
  end

  context '#destroy' do
    it 'should destroy feedback' do
      feedback = Feedback.last

      expect {
        delete :destroy, id: feedback.to_param
      }.to change(Feedback, :count).by(-1)
    end
  end
end
