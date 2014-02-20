module Payments
  class Factory

    def self.get type, payment
      service = case type
        when PaymentTransaction::TYPE_PAYPAL then Payments::Paypal
        when PaymentTransaction::TYPE_DWOLLA then Payments::Dwolla
      end  
      service.new payment
    end

  end
end


