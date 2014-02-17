FactoryGirl.define do

  factory :payment_recipient do
    association :payment    
    association :user
    amount { (rand(1000)/100.0).round(2)+0.01 }
  end

end
