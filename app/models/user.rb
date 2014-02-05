class User < ActiveRecord::Base

  belongs_to :company
  has_one :account
  has_many :users_teams, class_name: "TeamsUsers"
  has_many :teams, through: :users_teams

  accepts_nested_attributes_for :company, :allow_destroy => true
  accepts_nested_attributes_for :account, :allow_destroy => true

  validates_presence_of :name
  validates_presence_of :company
  validates :contact_email, :email => true, :unless => "self.contact_email.blank?"

  mount_uploader :avatar, AvatarUploader

  def company_attributes= company
    company[:created_by] = self
    company[:contact_person] = self
    super company
  end

end

