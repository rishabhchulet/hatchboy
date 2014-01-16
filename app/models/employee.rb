class Employee < ActiveRecord::Base
  
  belongs_to :company
  has_many :employee_teams, class_name: "TeamsEmployees"
  has_many :teams, through: :employee_teams
  
  validates :company, :presence => true
  validates :name, :presence => true
  validates :contact_email, :email => true, :unless => "self.contact_email.blank?"
  
end
