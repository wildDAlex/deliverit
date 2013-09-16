
FactoryGirl.define do
  factory :valid_user, :class => User do |f|
    f.email "john@doe.com"
    f.password "qwertyui"
  end
end