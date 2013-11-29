FactoryGirl.define do
  
  sequence(:password) do
    sample =  [('a'..'z'),('A'..'Z'),('0'..'9')].map{|i| i.to_a}.flatten
    (0...Devise.password_length.min).map do
      sample[rand(sample.length)]
    end.join
  end

  factory :not_confirmed_account, :class => Account do

    email do
      begin 
        email = Faker::Internet.email
      end while Account.where(email: email).any?
      email
    end
    password { @password = generate(:password) }
    password_confirmation @password
    
    after :build do |account, evaluator|
      unless evaluator.profile
        account.profile = build :customer
      end
    end
    
    factory :account do
      confirmed_at Time.now
    end
  end
end
