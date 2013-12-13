# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  
  sequence :role do
    roles = ["designer", "manager", "developer", "CEO", "teamlider" ]
    roles[rand(roles.count)]
  end
  
  sequence :status do
    statuses = ["outsourced", "temporary", "fulltime", "hourly rate"]
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
