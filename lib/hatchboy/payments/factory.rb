module Hatchboy
  module Payments
    class Factory

      class << self
        include ApplicationHelper

        def get type, params
          service = case type
            when Payment::TYPE_PAYPAL then Payments::Paypal
            when Payment::TYPE_DWOLLA then Payments::Dwolla
            when Payment::TYPE_STRIPE then Payments::Stripe
            else not_found
          end
          service.new params
        end
      end

    end
  end
end
