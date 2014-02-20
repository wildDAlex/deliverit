require 'spec_helper'
require 'requests_helper'
#require "selenium-webdriver"

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

      it "make shares public and private" do
        @share = FactoryGirl.create(:share, user: @user, public: false)
        visit share_path(@share)
        click_link "Make public"
        page.should have_content "Share was successfully updated."
        signing_out
        visit "/download/#{@share.filename}"
        page.response_headers['Content-Type'].should eq @share.content_type
        login(@user)
        visit share_path(@share)
        click_link 'Make private'
        signing_out
        visit "/download/#{@share.filename}"
        page.should have_content("You need to sign in or sign up before continuing.")
      end

      it "Shows pagination links" do
        26.times do
          FactoryGirl.create(:share, user: @user)
        end
        visit shares_path
        within(:xpath, "//div[@class='pagination pagination-centered']") do
          page.should have_selector(:xpath, '//ul/li/a')
        end
      end

      it "Show image-share page with links" do
        visit shares_url
        attach_file('share[file]', Rails.root.join('public','test_image.jpg'))
        click_button "Create Share"
        within(:xpath, "//div[@class='row']/div[@class='span12']") do
          page.should have_selector(:xpath, '//p/a/img')
          page.should have_content "Preview with link to full version:"
          page.should have_content "HTML inline with link to full version:"
          page.should have_selector(:xpath, "//p/a[@href='#{download_share_link(Share.last)}']")
        end
      end

      it "Show non-image-share page with links" do
        visit shares_url
        attach_file('share[file]', Rails.root.join('public','test_file.txt'))
        click_button "Create Share"
        within(:xpath, "//div[@class='row']/div[@class='span12']") do
          page.should_not have_selector(:xpath, '//p/a/img')
          page.should_not have_content "Preview with link to full version:"
          page.should_not have_content "HTML inline with link to full version:"
          page.should have_selector(:xpath, "//p/a[@href='#{download_share_link(Share.last)}']")
        end
      end

      it "Render 404 page when share doesn't exist" do
        @share = FactoryGirl.create(:share, user: @user)
        @share.destroy
        visit share_path @share
        page.should have_content "404: Page not found."
      end
    end
  end

  context "downloading" do
    before :each do
      DatabaseCleaner.clean
      @admin_user = FactoryGirl.create(:valid_user)
      @user = FactoryGirl.create(:valid_user)
      @user2 = FactoryGirl.create(:valid_user)
      @share = FactoryGirl.create(:share, user: @user, public: false)
      @public_share = FactoryGirl.create(:not_image_share, user: @user, public: true)
    end

    describe "non-full version" do
      it "don't increase counter" do
        login(@user)
        expect{
          visit "/download/thumb/#{@share.filename}"
        }.to change{@share.reload.download_count}.by(0)
        signing_out
      end
    end

    describe "full version" do
      it "increases counter" do
        login(@user)
        expect{
        visit "/download/#{@share.filename}"
        }.to change{@share.reload.download_count}.from(0).to(1)
        signing_out
      end
    end

    describe "public shares" do
      it "allowed for all" do
        visit share_url(@public_share)
        page.should have_content "test_file.txt"
        visit "/download/#{@public_share.filename}"
        page.response_headers['Content-Type'].should eq @public_share.content_type
        login(@user2)
        visit "/download/#{@public_share.filename}"
        page.response_headers['Content-Type'].should eq @public_share.content_type
        signing_out
        login(@user)
        visit "/download/#{@public_share.filename}"
        page.response_headers['Content-Type'].should eq @public_share.content_type
        signing_out
      end
    end

    describe "private shares" do
      it "allowed for owner" do
        login(@user)
        visit share_url(@share)
        page.should have_content "test_image.jpg"
        visit "/download/#{@share.filename}"
        page.response_headers['Content-Type'].should eq @share.content_type
        signing_out
      end
      it "not allowed for another user and guest" do
        login(@user2)
        visit share_url(@share)
        page.should have_content("You are not authorized to access this page.")
        visit "/download/#{@share.filename}"
        page.should have_content("Forbidden. You don't have permission to access this file.")
        signing_out
        visit share_url(@share)
        page.should_not have_content "test_image.jpg"
        visit "/download/#{@share.filename}"
        page.should have_content("You need to sign in or sign up before continuing.")
      end
    end
  end

  context "filter" do
    before :each do
      DatabaseCleaner.clean
      @user = FactoryGirl.create(:valid_user)
      @img_share = FactoryGirl.create(:share, user: @user)
      @txt_share = FactoryGirl.create(:not_image_share, user: @user)
    end
    describe "by content-type" do
      it "returns only filtering shares" do
        login(@user)
        visit shares_path
        page.should have_content "test_image.jpg"
        page.should have_content "test_file.txt"
        visit "/content-type/image"
        page.should have_content "test_image.jpg"
        page.should_not have_content "test_file.txt"
        visit "/content-type/text"
        page.should_not have_content "test_image.jpg"
        page.should have_content "test_file.txt"
      end
    end
  end

end