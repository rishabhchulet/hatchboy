class StripeRecipient < ActiveRecord::Base
  belongs_to :user
  
  attr_accessor :full_name, :stripe_token

  validates_presence_of :recipient_token, :last_4_digits, :user
end