require "spec_helper"

describe PaymentTransaction do

  specify do
    should be_kind_of PaymentTransaction
    should respond_to :payment
  end

end
