require 'spec_helper'

describe Share do

  context "matching" do

    before :each do
      @user = FactoryGirl.create(:valid_user)
      @share = FactoryGirl.create(:share, user: @user)
    end

    it "has a valid factory" do
      @share.should be_valid
    end

    it "changed original filename" do
      @share.file.should_not eq 'test_image.jpg'
    end

    it "saves original filename in database" do
      @share.original_filename.should eq 'test_image.jpg'
    end

  end

  context "non-matching" do

    it "is invalid without file" do
      FactoryGirl.build(:share, user: FactoryGirl.create(:valid_user), file: nil).should_not be_valid
    end

    it "is invalid without user" do
      FactoryGirl.build(:share, user: nil).should_not be_valid
    end

  end

end