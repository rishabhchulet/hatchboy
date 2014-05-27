class PaymentTransaction < ActiveRecord::Base
  TYPE_PAYPAL = 'paypal'
  TYPE_DWOLLA = 'dwolla'
  TYPE_STRIPE = 'stripe'

  belongs_to :payment

  self.inheritance_column = :_type_disabled

end
