require 'spec_helper'

describe SharesController do

  describe "GET #index" do
    it "populates an array of shares" do
      user = FactoryGirl.create(:valid_user)
      sign_in user
      share = FactoryGirl.create(:share, user: user)
      get :index
      assigns(:shares).should eq([share])
    end
  end

end