class Customer < ActiveRecord::Base 
 
  belongs_to :company
  has_one :account, :as => :profile
  
  accepts_nested_attributes_for :company, :allow_destroy => true
  accepts_nested_attributes_for :account, :allow_destroy => true
  
  validates_presence_of :name
  validates_presence_of :company

  def company_attributes= company
    company[:created_by] = self
    company[:contact_person] = self
    super company
  end  
  
end
