module Hatchboy
  module Payments
    class Factory

      class << self
        include ApplicationHelper

        def get type
          service = case type
            when PaymentTransaction::TYPE_PAYPAL then Payments::Paypal
            when PaymentTransaction::TYPE_DWOLLA then Payments::Dwolla
            else not_found
          end
          service.new
        end
      end

    end
  end
end
