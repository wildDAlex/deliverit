
FactoryGirl.define do
  factory :share, :class => Share do |f|
    f.file File.open(Rails.root.join('public','test_image.jpg'))
  end
end

FactoryGirl.define do
  factory :not_image_share, :class => Share do |f|
    f.file File.open(Rails.root.join('public','test_file.txt'))
  end
end

FactoryGirl.define do
  factory :invalid_share, parent: :contact do |f|
    f.file nil
  end
end
