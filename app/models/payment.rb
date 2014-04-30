class Payment < ActiveRecord::Base

  STATUS_PREPARED = "prepared"
  STATUS_SENT = "sent"
  
  belongs_to :company
  belongs_to :created_by,  class_name: "User"
  has_many   :transactions, class_name: "PaymentTransaction"
  has_many   :recipients,  class_name: "PaymentRecipient"
  accepts_nested_attributes_for :recipients

  validates :company, :created_by, :description, presence: true

  before_create :default_attributes

  def amount
    self.recipients.map(&:amount).sum.round(2)
  end

  private

  def default_attributes
    self.status ||= STATUS_PREPARED
    self.deleted ||= false
    true
  end

end

