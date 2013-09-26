require 'spec_helper'
require 'requests_helper'
require "selenium-webdriver"

describe Share do

  context "matching requests" do

    before :each, :turn => :second do
      login(FactoryGirl.create(:valid_user))
    end

    it "request a log in" do
      visit shares_path
      page.should have_content("You need to sign in or sign up before continuing.")
    end

    it "log in with valid user", :turn => :second do
      page.should have_content("Signed in successfully")
    end

    describe "manage shares" do
      before :each do
        DatabaseCleaner.clean
        @user = FactoryGirl.create(:valid_user)
        login(@user)
      end

      it "Adds a new share and displays the result" do
        visit shares_url
        expect{
          attach_file('share[file]', Rails.root.join('public','test_image.jpg'))
          click_button "Create Share"
        }.to change(Share, :count).by(1)
        page.should have_content "Share was successfully created"
        within "body" do
          page.should have_content "test_image.jpg"
        end
      end

      it "Deletes a share" do
        @share = FactoryGirl.create(:share, user: @user)
        visit shares_path
        expect{
          click_link 'Delete'
          #alert = page.driver.browser.switch_to.alert
          #alert.accept
        }.to change(Share, :count).by(-1)
        page.should have_content "Share was successfully deleted"
      end
    end
  end

end