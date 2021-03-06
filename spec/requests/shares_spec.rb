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
        visit shares_path
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
        visit shares_path
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
        visit shares_path
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

      it "call file by name uploading files from user local path" do
        require 'fileutils'
        FileUtils.cp(Rails.root.join('public', 'image_from_local_path.jpg').to_s, Rails.application.secrets.local_upload_path+"/#{@user.id}/image_from_local_path.jpg")
        visit "/f/#{@user.id}/image_from_local_path.jpg"
        page.should have_content("image_from_local_path.jpg")
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
      @public_share = FactoryGirl.create(:not_image_share, user: @user, public: true, tag_list: "TagThree")
      @public_image = FactoryGirl.create(:share, user: @user, public: true, tag_list: "TagOne, TagTwo")
      @private_image = FactoryGirl.create(:share, user: @user, public: false, tag_list: "TagOne, TagThree")
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
        login(@user2)
        expect{
        visit "/download/#{@public_image.filename}"
        }.to change{@public_image.reload.download_count}.from(0).to(1)
        signing_out
      end

      it "don't increases counter if image belongs to user" do
        login(@user)
        expect{
          visit "/download/#{@public_image.filename}"
        }.not_to change{@public_image.reload.download_count}
        signing_out
      end

    end

    describe "public shares" do
      it "allowed for all" do
        visit share_path(@public_share)
        page.should have_content "test_file.txt"
        visit "/f/#{@user.id}/#{@public_share.original_filename}"
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
        visit share_path(@share)
        page.should have_content "test_image.jpg"
        visit "/f/#{@user.id}/#{@share.original_filename}"
        page.should have_content "test_image.jpg"
        visit "/download/#{@share.filename}"
        page.response_headers['Content-Type'].should eq @share.content_type
        signing_out
      end
      it "not allowed for another user and guest" do
        login(@user2)
        visit share_path(@share)
        page.should have_content("You are not authorized to access this page.")
        visit "/f/#{@user.id}/#{@share.original_filename}"
        page.should have_content("Forbidden. You don't have permission to access this file.")
        visit "/download/#{@share.filename}"
        page.should have_content("Forbidden. You don't have permission to access this file.")
        signing_out
        visit share_path(@share)
        page.should_not have_content "test_image.jpg"
        visit "/f/#{@user.id}/#{@share.original_filename}"
        page.should_not have_content "test_image.jpg"
        visit "/download/#{@share.filename}"
        page.should have_content("You need to sign in or sign up before continuing.")
      end
      it "marked by Private icon in thumb list" do
        login(@user)
        @public_share.destroy!
        @public_image.destroy!
        visit '/content-type/images'
        expect(page).to have_selector("div[class='thumb-info']>span[class='private']")
      end
    end

    describe  "share with tags" do
      it "show own tags" do
        login(@user)
        visit share_path(@public_image)
        expect(page).to have_selector("input[value='images, TagOne, TagTwo']")
        signing_out
      end
      it "doesn't show anothers tags" do
        @share_with_tags = FactoryGirl.create(:share, user: @user, public: true, tag_list: "TagOne, TagTwo")
        login(@user2)
        visit share_path(@public_image)
        expect(page).not_to have_selector("input[value='images, TagOne, TagTwo']")
        signing_out
      end
    end
  end

  context "filter" do
    before :each do
      DatabaseCleaner.clean
      @user = FactoryGirl.create(:valid_user)
      @img_share = FactoryGirl.create(:share, user: @user, tag_list: "TagOne")
      @txt_share = FactoryGirl.create(:not_image_share, user: @user, tag_list: "TagTwo")
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
    describe  "by tag" do
      it "returns only shares with specified tag" do
        login(@user)
        tag = Tag.owned_by(@user).find_by_name("TagOne")
        visit share_path(tag)
        page.should have_content "test_image.jpg"
        page.should_not have_content "test_file.txt"
      end
    end
  end

end