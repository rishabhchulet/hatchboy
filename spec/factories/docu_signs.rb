# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :docu_sign do
    company nil
    user nil
    envelope_id "MyString"
    status "MyString"
  end
end
