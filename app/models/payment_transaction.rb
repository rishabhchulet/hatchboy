class PaymentTransaction < ActiveRecord::Base
  TYPE_PAYPAL = 'paypal'
  TYPE_DWOLLA = 'dwolla'

  belongs_to :payment

  self.inheritance_column = :_type_disabled

end
