class Account < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :user

  accepts_nested_attributes_for :user, :allow_destroy => true

  validates_presence_of :user

  def has_role? role
    role.to_sym == :customer
  end

  def user_attributes= attr
    attr[:id] = self.user.id if self.user
    super
  end

end

