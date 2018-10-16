class PaymentTransaction < ActiveRecord::Base
  belongs_to :payment

  self.inheritance_column = :_type_disabled

end
