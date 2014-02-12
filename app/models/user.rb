class User < ActiveRecord::Base

  belongs_to :company
  has_one :account

  has_many :user_teams, class_name: "TeamsUsers"
  has_many :teams, through: :user_teams

  scope :without_account, -> { joins("LEFT JOIN accounts AS r10 ON r10.user_id = users.id").where("r10.id IS NULL") }
  scope :with_account, -> { joins("LEFT JOIN accounts AS r11 ON r11.user_id = users.id").where("r11.id IS NOT NULL") }

  accepts_nested_attributes_for :company, :allow_destroy => true
  accepts_nested_attributes_for :account, :allow_destroy => true

  validates_presence_of :name
  validates_presence_of :company
  validates :contact_email, presence: true, :email => true, :if => "self.account.blank?"
  validates_uniqueness_of :contact_email, scope: [:company_id], message: "has already been added"

  mount_uploader :avatar, AvatarUploader

  def company_attributes= company
    company[:created_by] = self
    company[:contact_person] = self
    super company
  end

end

