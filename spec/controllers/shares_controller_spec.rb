require 'spec_helper'

describe SharesController do

  before :each do
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

end