FactoryGirl.define do

  factory :company do

    name do
      begin
        name = Faker::Company.name
      end while Company.where(name: name).any?
      name
    end

    description { Faker::Lorem.paragraph }

    after :build do |company, evaluator|
      unless evaluator.created_by
        company.created_by = build :user, company: company, role: 'CEO'
      end
      company.contact_person = company.created_by
    end
  end
end
