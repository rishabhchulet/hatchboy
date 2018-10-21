class PaymentRecipient < ActiveRecord::Base

  belongs_to :payment
  belongs_to :user

  before_save :round_amount

  validates :user, :amount, presence: true
  validate :user, :should_have_account

  validate :amount_cannot_be_less_or_equal_to_zero

  private

  def round_amount
    self.amount = self.amount.round(2)
  end  

  def amount_cannot_be_less_or_equal_to_zero
    errors.add(:amount, "can't be less or equal to zero") if self.amount.to_f <= 0
  end

  def should_have_account
    #user should have account email to pay on
    errors.add(:user, "should login at least one time before you can pay him") if user.nil? or user.account.nil?
  end

 
end
