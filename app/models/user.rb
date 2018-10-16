class User < ActiveRecord::Base
  ADMIN_ROLES = ['CEO', 'Manager']

  include PublicActivity::Model
  tracked except: :update,
          owner: ->(controller, model) { controller && controller.current_user },
          company_id: ->(controller, user) { user.company.id },
          comments: ->(controller, user) { {name: user.name}.to_json }

  belongs_to :company
  has_one :account

  has_one :stripe_recipient, :dependent => :destroy

  has_many :user_teams, class_name: "TeamsUsers"
  has_many :teams, through: :user_teams
  has_many :worklogs, :class_name => "WorkLog", :dependent => :destroy

  has_many :user_multi_ratings, foreign_key: "rater_id", dependent: :destroy
  has_many :user_avg_ratings, foreign_key: "rater_id", dependent: :destroy
  has_many :multi_ratings_by_users, foreign_key: "rated_id", class_name: "UserMultiRating", dependent: :destroy
  has_many :avg_ratings_by_users, foreign_key: "rated_id", class_name: "UserAvgRating", dependent: :destroy

  has_one :subscription, dependent: :destroy
  has_many :unsubscribed_teams, dependent: :destroy

  has_one :dashboard_activity_filter, dependent: :destroy

  scope :without_account, -> { joins("LEFT JOIN accounts AS r10 ON r10.user_id = users.id").where("r10.id IS NULL") }
  scope :with_account, -> { joins("LEFT JOIN accounts AS r11 ON r11.user_id = users.id").where("r11.id IS NOT NULL") }

  accepts_nested_attributes_for :company, :allow_destroy => true
  accepts_nested_attributes_for :account, :allow_destroy => true

  validates_presence_of :name
  validates_presence_of :company
  validates :contact_email, presence: true, :email => true, :unless => "self.contact_email.blank?"
#  validates_uniqueness_of :contact_email, scope: [:company_id], message: "has already been added"

  mount_uploader :avatar, AvatarUploader

  before_create :set_default_avatar, unless: "self.avatar?"

  def company_attributes= company
    company[:created_by] = self
    company[:contact_person] = self
    super company
  end
  
  def update_rating!
    self.rating = avg_ratings_by_users.current_period.average(:avg_score)
    save!
  end

  def can_rate?(rated_user)
    user_multi_ratings.current_period.where(rated_id: rated_user.id).count < USER_MULTI_RATING_ASPECTS.count
  end

  private

    def set_default_avatar
      self.avatar = File.open(Dir.glob(Rails.root.join('app','assets','images','images','user_default_avatars','*')).shuffle.first)
      write_avatar_identifier
    end
end