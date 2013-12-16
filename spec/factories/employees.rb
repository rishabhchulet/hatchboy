# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  
  sequence :role do
    roles = ["Manager", "Developer", "Designer", "Fron-end developer", "CEO", "Team-Leader" ]
    roles[rand(roles.count)]
  end
  
  sequence :status do
    statuses = ["Full day", "Temporary", "Half-day", "Fired", "Outsourcer"]
    statuses[rand(statuses.count)]
  end
  
  factory :employee do
    
    association :company
    
    name { Faker::Name.name}
    contact_email { Faker::Internet.email }
    role { generate :role }
    status { generate :status }
  end
end
