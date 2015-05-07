require 'rails_helper'

RSpec.describe Operation::VideosController, :type => :controller do
  describe 'PATCH #update' do 
    before :each do
      admin = create :admin
      session[:admin_id] = admin.id
      @video = create(:video, snapshot: 'xxx.jpg')
      @star = @video.star
    end

    context "valid attributes" do
      it "locates the requested @video" do
        patch :update, id: @video, video: attributes_for(:video)
        expect(assigns(:video)).to eq(@video)
      end  

      it "changes @video's attributes" do 
        valid_upload = fixture_file_upload('about.png')
        patch :update, id: @video, video: attributes_for(:video, snapshot: valid_upload)
        @video.reload
        expect(@video.snapshot.size > 0).to be true
      end

      it "redirects to the star's edit page" do
        patch :update, id: @video, video: attributes_for(:video) 
        expect(response).to redirect_to edit_operation_star_url(@star) 
      end 
    end

    context "with invalid attributes" do
      before :each do
        @invalid_upload = fixture_file_upload('video_for_test.mp4')
      end

      it "does not change the video's attributes" do
        patch :update, id: @video, video: attributes_for(:video, snapshot: @invalid_upload) 
        @video.reload
        expect(@video.snapshot.size == 0).to be true
      end

      it "re-renders the edit template" do 
        patch :update, id: @video, video: attributes_for(:video, snapshot: @invalid_upload) 
        expect(response).to render_template :edit
      end
    end
  end

  describe 'DELETE #destroy' do 
    before :each do
      admin = create :admin
      session[:admin_id] = admin.id
      @video = create(:video) 
      @star = @video.star
    end

    it "deletes the video" do 
      expect{delete :destroy, id: @video}.to change(Video,:count).by(-1)
    end

    it "redirects to videos#index" do
      delete :destroy, id: @video 
      expect(response).to redirect_to edit_operation_star_url(@star)
    end
  end

end
