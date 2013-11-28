class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  
  belongs_to :company
  accepts_nested_attributes_for :company, :allow_destroy => true
  validates_presence_of :company

  def company_attributes= company
    company[:created_by] = self
    company[:contact_person] = self
    super company
  end  
  
  def has_role? role
    role.to_sym == :customer
  end
  
end
