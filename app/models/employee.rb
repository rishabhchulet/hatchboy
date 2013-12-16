class Employee < ActiveRecord::Base
  
  belongs_to :company
  validates :company, :presence => true
  validates :name, :presence => true
  validates :contact_email, :email => true, :unless => "self.contact_email.blank?"
  
end
