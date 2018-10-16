FactoryGirl.define do

  factory :payment do
    ignore do
      recipients_count 0
    end

    description { Faker::Lorem.sentence }
    association :company
    created_by { create(:user, company: company) }

    after(:create) do |payment, evaluator|
      if evaluator.recipients_count > 0
        payment.recipients = create_list(:payment_recipient, evaluator.recipients_count, payment: payment)
      end
    end
  end

end
