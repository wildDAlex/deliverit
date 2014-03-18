require 'spec_helper'
require 'requests_helper'
#require "selenium-webdriver"

describe Api do
  context "matching requests" do

    before :each do
      @user = FactoryGirl.create(:valid_user)
      @valid_request_headers = {
          "Accept" => "application/json",
          "Content-Type" => "application/json",
          "HTTP_USER_EMAIL" => @user.email,
          "HTTP_USER_TOKEN" => @user.authentication_token
      }
    end

    describe "GET index" do
      it 'returns all shares' do
        3.times do
          FactoryGirl.create(:share, user: @user)
        end
        get "/api/v1/shares/", {"share" => nil}, {
            "Accept" => "application/json",
            "Content-Type" => "application/json",
            "HTTP_USER_EMAIL" => @user.email,
            "HTTP_USER_TOKEN" => @user.authentication_token
        }
        expect(response.status).to eq 200
      end
    end
  end

  context "non-matching requests" do

  end
end