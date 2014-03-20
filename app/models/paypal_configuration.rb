class PaypalConfiguration < ActiveRecord::Base
  belongs_to :company

  validates_presence_of :login, :password, :signature
end
