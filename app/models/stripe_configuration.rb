class StripeConfiguration < ActiveRecord::Base
  belongs_to :company

  validates_presence_of :secret_key, :public_key, :company
end
