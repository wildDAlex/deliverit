
FactoryGirl.define do
  factory :tag_one, :class => Tag do |f|
    f.name "TagOne"
  end

  factory :tag_two, :class => Tag do |f|
    f.name "TagTwo"
  end
end