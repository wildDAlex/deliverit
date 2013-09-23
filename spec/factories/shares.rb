
FactoryGirl.define do
  factory :share, :class => Share do |f|
    f.file File.open(Rails.root.join('public','test_image.jpg'))
  end

FactoryGirl.define do
  factory :invalid_share, parent: :contact do |f|
    f.file nil
  end
end
end