require 'faker'

FactoryGirl.define do
  factory :valid_user, :class => User do |f|
    f.email {Faker::Internet.email}
    f.password {Faker::Internet.password*2} # x2 uses for cases when faker generates too short password
    after(:create) { |user| user.confirm! }
  end
end