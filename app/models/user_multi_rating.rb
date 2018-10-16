class UserMultiRating < ActiveRecord::Base
  
  RATE_TIMEOUT = 1
  MAX_RATING = 10

  belongs_to :rated, class_name: "User"
  belongs_to :rater, class_name: "User"

  validates_presence_of :rated_id, :rater_id, :score, :aspect_code
  validates_inclusion_of :score, in: 1..MAX_RATING, message: "can only be between 1 and #{MAX_RATING}."
  validates_inclusion_of :aspect_code, in: USER_MULTI_RATING_ASPECTS.keys
  validates_uniqueness_of :rater_id, scope: [:rated_id, :aspect_code, :date_period], message: "you can rate only once in #{RATE_TIMEOUT} months for each user by each aspect"

  after_save :create_avg_rating, if: :answered_all_aspects?
  before_validation :default_attributes, on: :create

  scope :current_period, -> { where(date_period: (RATE_TIMEOUT-1).month.ago.at_beginning_of_month) }

  private

    def create_avg_rating
      rated_user = User.find(self.rated_id) or not_found
      rated_user.avg_ratings_by_users.create!(rater_id: self.rater_id, avg_score: @avg_score, date_period: self.date_period)
    end

    def default_attributes
      self.date_period ||= (RATE_TIMEOUT-1).month.ago.at_beginning_of_month
    end

    def answered_all_aspects?
      rater_user = User.find(self.rater_id) or not_found
      @avg_score = rater_user.user_multi_ratings.current_period.where(rated_id: self.rated_id).having('count(aspect_code) >= ?', USER_MULTI_RATING_ASPECTS.count).average(:score)
    end
end