class Company < ActiveRecord::Base

  belongs_to :created_by, class_name: "Customer"
  belongs_to :contact_person, class_name: "Customer"
  has_many :customers
  
  validates_presence_of :created_by
  validates :name, uniqueness: { case_sensitive: false }, presence: true
end
