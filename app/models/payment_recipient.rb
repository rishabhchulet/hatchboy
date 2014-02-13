class PaymentRecipient < ActiveRecord::Base

  belongs_to :payment
  belongs_to :recipient, class_name: "User"

  before_save :round_amount

  validates :payment, :recipient, :amount, presence: true
  validate :amount_cannot_be_less_or_equal_to_zero

  private

  def round_amount
    self.amount = self.amount.round(2)
  end  

  def amount_cannot_be_less_or_equal_to_zero
    errors.add(:amount, "can't be less or equal to zero") if self.amount.to_f <= 0
  end
 
end
