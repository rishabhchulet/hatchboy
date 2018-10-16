class UserAvgRating < ActiveRecord::Base
  belongs_to :rated, class_name: "User"
  belongs_to :rater, class_name: "User"

  validates_presence_of :rated_id, :rater_id, :avg_score
  validates_inclusion_of :avg_score, in: 1..UserMultiRating::MAX_RATING, message: "can only be between 1 and #{UserMultiRating::MAX_RATING}."
  validates_uniqueness_of :rater_id, scope: [:rated_id, :date_period]

  after_save :update_user_rating
  before_validation :default_attributes, on: :create

  scope :current_period, -> { where(date_period: (UserMultiRating::RATE_TIMEOUT-1).month.ago.at_beginning_of_month) }
  
  private

    def default_attributes
      self.date_period ||= (UserMultiRating::RATE_TIMEOUT-1).month.ago.at_beginning_of_month
    end

    def update_user_rating
      self.rated.update_rating!
    end
end