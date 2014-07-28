require 'spec_helper'
require 'requests_helper'

describe SharesController do

  before :each do
    DatabaseCleaner.clean
    @user = FactoryGirl.create(:valid_user)
    @user2 = FactoryGirl.create(:valid_user)
    sign_in @user
    @share = FactoryGirl.create(:share, user: @user, public: false)
    @public_share = FactoryGirl.create(:share, user: @user, public: true)
  end

  describe "GET #index" do
    it "populates an array of shares" do
      get :index
      assigns(:shares).should eq([@public_share, @share])
    end
    it "renders the :index view" do
      get :index
      response.should render_template :index
    end

    context "by not owner" do
      it "not show another user shares in index" do
        sign_out @user
        sign_in @user2
        get :index
        assigns(:shares).should_not eq([@share])
      end
    end

    context "by guest user" do
      it "not show shares index" do
        sign_out @user
        get :index
        response.should_not render_template :index
      end
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

    context "by not owner" do
      it "not show another user share if not public" do
        sign_out @user
        sign_in @user2
        get :show, id: @share
        response.should redirect_to root_path
      end

      it "show another user share if public" do
        sign_out @user
        sign_in @user2
        get :show, id: @public_share
        response.should render_template :show
      end
    end

    context "by guest user" do
      it "not show if not public" do
        sign_out @user
        get :show, id: @share
        response.should redirect_to root_path
      end
      it "show if public" do
        sign_out @user
        get :show, id: @public_share
        response.should render_template :show
      end
    end

  end

  describe "create" do
    context "with valid attributes" do
      it "creates a new share" do
        expect{
          Share.create(file: @share.file, user: @user, public: false)
        }.to change(Share, :count).by(1)
      end
    end
  end

  #describe "POST create" do
  #  context "with valid attributes" do
  #    it "creates a new share" do
  #      expect{
  #        post :create, share: FactoryGirl.attributes_for(:share)
  #      }.to change(Share, :count).by(1)
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

    context "by not owner" do
      it "not located the requested @share" do
        sign_out @user
        sign_in @user2
        put :update, id: @share, share: FactoryGirl.attributes_for(:share)
        response.should redirect_to root_path
        put :update, id: @public_share, share: FactoryGirl.attributes_for(:share)
        response.should redirect_to root_path
      end

      it "not changes @shares's attributes" do
        sign_out @user
        sign_in @user2
        put :update, id: @share, share: FactoryGirl.attributes_for(:share, original_filename: "123.jpg", public: true)
        @share.reload
        @share.original_filename.should eq("test_image.jpg")
        @share.public.should be_falsey

        put :update, id: @public_share, share: FactoryGirl.attributes_for(:share, original_filename: "123.jpg", public: false)
        @public_share.reload
        @public_share.original_filename.should eq("test_image.jpg")
        @public_share.public.should be_truthy
      end
    end

    context "by guest user" do
      it "not located the requested @share" do
        sign_out @user
        put :update, id: @share, share: FactoryGirl.attributes_for(:share)
        assigns(:share).should_not eq(@share)

        put :update, id: @public_share, share: FactoryGirl.attributes_for(:share)
        assigns(:share).should_not eq(@share)
      end

      it "not changes @shares's attributes" do
        sign_out @user
        put :update, id: @share, share: FactoryGirl.attributes_for(:share, original_filename: "123.jpg", public: true)
        @share.reload
        @share.original_filename.should eq("test_image.jpg")
        @share.public.should be_falsey

        put :update, id: @public_share, share: FactoryGirl.attributes_for(:share, original_filename: "123.jpg", public: false)
        @public_share.reload
        @public_share.original_filename.should eq("test_image.jpg")
        @public_share.public.should be_truthy
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
      response.should redirect_to shares_path
    end

    context "by not owner" do
      it "not deletes the share" do
        sign_out @user
        sign_in @user2
        expect{
          delete :destroy, id: @share
        }.to change(Share, :count).by(0)

        expect{
          delete :destroy, id: @public_share
        }.to change(Share, :count).by(0)
      end
    end

    context "by guest user" do
      it "not deletes the share" do
        sign_out @user
        expect{
          delete :destroy, id: @share
        }.to change(Share, :count).by(0)

        expect{
          delete :destroy, id: @public_share
        }.to change(Share, :count).by(0)
      end
    end

  end
end