class Payment < ActiveRecord::Base

  STATUS_PREPARED = "prepared"
  STATUS_SENT = "sent"

  belongs_to :company
  belongs_to :created_by,  class_name: "User"
  has_many   :recipients,  class_name: "PaymentRecipient", autosave: true
  has_one    :transaction, class_name: "PaymentTransaction", autosave: true

  validates :company, :created_by, :status, :description, presence: true

  before_create :set_prepared_status

  def amount
    self.recipients.map(&:amount).sum.round(2)
  end  

  private

  def set_prepared_status
    self.status = STATUS_PREPARED
  end

end

