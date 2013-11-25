# Read about factories at https://github.com/thoughtbot/factory_girl
FactoryGirl.define do
  
  sequence(:password) do
    sample =  [('a'..'z'),('A'..'Z'),('0'..'9')].map{|i| i.to_a}.flatten
    (0...Devise.password_length.min).map do
      sample[rand(sample.length)]
    end.join
  end

  factory :user do
    name Faker::Name.name
    email do
      begin 
        email = Faker::Internet.email 
      end while User.where(email: email).any?
      email
    end
    password { @password = generate(:password) }
    password_confirmation @password
    confirmed_at Time.now
  end
end
