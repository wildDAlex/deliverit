require 'spec_helper'

FactoryGirl.define do
  factory :share, :class => Share do |f|
    f.file File.open(Rails.root.join('public','test_image.jpg'))
  end

FactoryGirl.define do
  factory :invalid_share, :class => Share do |f|
    #without file
  end
end
end