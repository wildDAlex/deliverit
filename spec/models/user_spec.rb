require 'spec_helper'

describe User do

  context "matching users" do
    it 'has a valid factory' do
      FactoryGirl.create(:valid_user).should be_valid
    end
  end

  context "non-matching users" do
    it "is invalid without a email" do
      FactoryGirl.build(:valid_user, email: nil).should_not be_valid
    end
  end

  it "creates user upload directory" do
    user = FactoryGirl.create(:valid_user)
    File.directory?(Rails.application.secrets.local_upload_path+"/#{user.id}").should be_true
  end

  it 'creates authentication_token' do
    user = FactoryGirl.create(:valid_user)
    user.authentication_token.should_not be_nil
  end

end