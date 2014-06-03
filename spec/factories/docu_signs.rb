# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :docu_sign do
    company
    user { create :user, company: company}
    docu_template nil
    envelope_key "MyString"
    status "MyString"

    after :build do |ds, evaluator|
      ds.class.skip_callback :validation, :before, :get_envelope
    end
  end

end
