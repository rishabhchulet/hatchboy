# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :company do
    name "MyString"
    description "MyText"
    created_by_id 1
    contact_person_id 1
  end
end
