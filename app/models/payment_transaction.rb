class PaymentTransaction < ActiveRecord::Base

  TYPE_PAYPAL = 'paypal'
  TYPE_DWOLLA = 'dwolla'

  belongs_to :payment
end
