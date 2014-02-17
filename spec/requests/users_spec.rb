require 'spec_helper'
require 'requests_helper'
#require "selenium-webdriver"

describe Share do

  before :each, :turn => :second do
    @admin_user = FactoryGirl.create(:valid_user)
    login(@admin_user)
  end

  describe "manage users" do
    before :each do
      DatabaseCleaner.clean
      @user = FactoryGirl.create(:valid_user)
      login(@user)
    end

    it "Adds a new confirmed user and displays the result" do
      @user2 = FactoryGirl.attributes_for(:valid_user)
      visit users_url
      expect{
        click_link "New"
        fill_in "user[email]", :with => @user2[:email]
        fill_in "user[password]", :with => @user2[:password]
        fill_in "user[password_confirmation]", :with => @user2[:password]
        click_button "Create User"
      }.to change(User, :count).by(1)
      page.should have_content "Account was successfully created"
      within "body" do
        page.should have_content @user2[:email]
      end
      User.last.confirmed_at.should_not be_nil
    end

    it "Deletes a user" do
      @user = FactoryGirl.create(:valid_user)
      visit users_path
      expect{
        click_link('Delete', :match => :first)
        #alert = page.driver.browser.switch_to.alert
        #alert.accept
      }.to change(User, :count).by(-1)
      page.should have_content "Account was successfully deleted."
    end

    it "don't delete admin user" do
      visit users_path
      expect{
        click_link 'Delete'
      }.to change(User, :count).by(0)
      page.should have_content "You can't delete administrator."
    end


    it "Shows pagination links" do
      26.times do
        FactoryGirl.create(:valid_user)
      end
      visit users_path
      within(:xpath, "//div[@class='pagination pagination-centered']") do
        page.should have_selector(:xpath, '//ul/li/a')
      end
    end

    it "Render 404 page when user doesn't exist" do
      @user = FactoryGirl.create(:valid_user)
      @user.destroy
      visit user_path @user
      page.should have_content "404: Page not found."
    end

  end

end