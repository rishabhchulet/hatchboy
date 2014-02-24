# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :post do
    user
    subject Faker::Lorem.sentence
    message Faker::Lorem.paragraph
  end

end
