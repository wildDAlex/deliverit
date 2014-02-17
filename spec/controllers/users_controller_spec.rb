require 'spec_helper'

describe UsersController do

  before :each do
    DatabaseCleaner.clean
    @user = FactoryGirl.create(:valid_user)
    @user2 = FactoryGirl.create(:valid_user)
    sign_in @user
  end

  describe "GET #index" do

    it "renders the :index view" do
      get :index
      response.should render_template :index
    end

    context "by not admin" do
      it "not show users index" do
        sign_out @user
        sign_in @user2
        get :index
        assigns(:users).should_not eq([@user])
      end
    end

    context "by guest user" do
      it "not show users index" do
        sign_out @user
        get :index
        response.should_not render_template :index
      end
    end
  end

  describe "create" do

    it "creates a new user" do
      expect{
        User.create(FactoryGirl.attributes_for(:valid_user))
      }.to change(User, :count).by(1)
    end

  end

end
