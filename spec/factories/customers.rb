FactoryGirl.define do
  
  factory :customer_without_account, :class => Customer do
    
    name Faker::Name.name

    after :build do |customer, evaluator|
      unless evaluator.company
        customer.company = build :company, created_by: customer, contact_person: customer
      end
    end
    
    factory :customer do
      
      after :build do |customer, evaluator|
        unless evaluator.account
          customer.account = build :account, :profile => customer 
        end
      end
    end
    
  end
end
