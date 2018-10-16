FactoryGirl.define do

  sequence :role do
    ["Manager", "Developer", "Designer", "Fron-end developer", "CEO", "Team-Leader"].sample
  end

  sequence :status do
    ["Full day", "Temporary", "Half-day", "Fired", "Outsourcer"].sample
  end

  factory :user_without_account, :class => User do

    name { Faker::Name.name }
    contact_email { Faker::Internet.email }
    role { generate :role }
    status { generate :status }

    after :build do |user, evaluator|
      unless evaluator.company
        user.company = build :company, created_by: user, contact_person: user
      end
    end

    factory :user do

      after :create do |user, evaluator|
        unless evaluator.account
          user.account = create :account, :user => user
        end
      end
    end

    trait :with_subscription do
      after :create do |user, evaluator|
        create :subscription, user: user
      end
    end 

  end
end

