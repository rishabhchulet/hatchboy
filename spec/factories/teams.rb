# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :team do
    company
    name { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    created_by { create(:user, company: company) }
  end
end
