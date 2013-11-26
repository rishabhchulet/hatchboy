class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  
  belongs_to :company
  accepts_nested_attributes_for :company, :allow_destroy => true

  after_save :set_creator_to_company

  def with_company
    self.build_company if self.company.nil?
    self
  end
  
  def has_role? role
    role.to_sym == :customer
  end

  private

  def set_creator_to_company
    self.company.created_by ||= self
    self.company.contact_person ||= self
    self.company.save!
  end
  
  
end
