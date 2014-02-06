FactoryGirl.define do

  sequence :role do
    roles = ["Manager", "Developer", "Designer", "Fron-end developer", "CEO", "Team-Leader" ]
    roles[rand(roles.count)]
  end

  sequence :status do
    statuses = ["Full day", "Temporary", "Half-day", "Fired", "Outsourcer"]
    statuses[rand(statuses.count)]
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

  end
end

