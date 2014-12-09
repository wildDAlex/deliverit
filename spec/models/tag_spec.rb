require 'spec_helper'

RSpec.describe Tag, :type => :model do
  before :each do
    @user = FactoryGirl.create(:valid_user)
    @tag = FactoryGirl.create(:tag_one, user: @user)
    @share = FactoryGirl.create(:share, user: @user, tag_list: @tag.name)
  end

  it "has a user" do
    expect(@tag.user).to eq(@user)
  end

  it "has a share" do
    expect(@tag.shares.first).to eq(@share)
  end

end
