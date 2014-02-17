FactoryGirl.define do

  factory :payment do
    description { Faker::Lorem.sentence }
    association :created_by, :factory => :user
    association :company

    ignore do
      recipients_count 0
    end

    after(:build) do |payment, evaluator|
      if evaluator.recipients_count > 0
        payment.recipients = create_list :payment_recipient, evaluator.recipients_count, payment: payment
      end
    end
  end

end
