require 'faker'

FactoryGirl.define do
  factory :valid_user, :class => User do |f|
    f.email {Faker::Internet.email}
    f.password {Faker::Internet.password}
    after(:create) { |user| user.confirm! }
  end
end