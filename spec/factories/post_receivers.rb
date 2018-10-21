# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :post_receiver, :class => 'PostReceiver' do
     receiver nil
     post nil
  end
end
