require 'spec_helper'
require 'requests_helper'

describe SharesController do

  before :each do
    DatabaseCleaner.clean
    @user = FactoryGirl.create(:valid_user)
    sign_in @user
    @share = FactoryGirl.create(:share, user: @user)
  end

  describe "GET #index" do
    it "populates an array of shares" do
      get :index
      assigns(:shares).should eq([@share])
    end
    it "renders the :index view" do
      get :index
      response.should render_template :index
    end
  end

  describe "GET #show" do
    it "assigns the requested share to @share" do
      get :show, id: @share
      assigns(:share).should eq(@share)
    end
    it "renders the #show view" do
      get :show, id: @share
      response.should render_template :show
    end
  end

  describe "create" do
    context "with valid attributes" do
      it "creates a new share" do
        expect{
          Share.create(file: @share.file, user: @user)
        }.to change(Share, :count).by(1)
      end
    end
  end

  #describe "POST create" do
  #  context "with valid attributes" do
  #    it "creates a new share" do
  #      expect{
  #        post :create, share: FactoryGirl.attributes_for(:share)
  #      }.to change(Share,:count).by(1)
  #    end
  #  end
  #end

  describe 'PUT update' do
    context "valid attributes" do
      it "located the requested @share" do
        put :update, id: @share, share: FactoryGirl.attributes_for(:share)
        assigns(:share).should eq(@share)
      end

      it "changes @shares's attributes" do
        put :update, id: @share, share: FactoryGirl.attributes_for(:share, original_filename: "123.jpg")
        @share.reload
        @share.original_filename.should eq("123.jpg")
      end

      it "redirects to the updated share" do
        put :update, id: @share, share: FactoryGirl.attributes_for(:share)
        response.should redirect_to @share
      end

    end
  end

  describe 'DELETE destroy' do
    it "deletes the share" do
      expect{
        delete :destroy, id: @share
      }.to change(Share, :count).by(-1)
    end

    it "redirects to shares#index" do
      delete :destroy, id: @share
      response.should redirect_to shares_url
    end
  end

end