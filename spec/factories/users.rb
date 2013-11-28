FactoryGirl.define do
  
  sequence(:password) do
    sample =  [('a'..'z'),('A'..'Z'),('0'..'9')].map{|i| i.to_a}.flatten
    (0...Devise.password_length.min).map do
      sample[rand(sample.length)]
    end.join
  end

  factory :not_confirmed_user, :class => User do
    name Faker::Name.name
    email do
      begin 
        email = Faker::Internet.email
      end while User.where(email: email).any?
      email
    end
    password { @password = generate(:password) }
    password_confirmation @password
    
    after :build do |user, evaluator|
      unless evaluator.company
        company = build :company, created_by: user, contact_person: user
        user.company = company
      end
    end
    
    factory :user do
      confirmed_at Time.now
    end
  end
end
