class Company < ActiveRecord::Base

  belongs_to :created_by, class_name: "User"
  belongs_to :contact_person, class_name: "User"
  has_many :users
  has_many :sources
  has_many :teams
  has_many :payments
  has_one :paypal_configuration, :dependent => :destroy
  has_one :stripe_configuration, :dependent => :destroy

  validates_presence_of :created_by
  validates :name, uniqueness: { case_sensitive: false }, presence: true
end

