class Company < ActiveRecord::Base
  belongs_to :created_by, class_name: "User"
  belongs_to :contact_person, class_name: "User"

  validates :name, uniqueness: { case_sensitive: false }, presence: true
end
