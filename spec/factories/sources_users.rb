# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sources_user do
    association :source
    name { Faker::Name.name}
    email {Faker::Internet.email}
    employee nil
  end
end
