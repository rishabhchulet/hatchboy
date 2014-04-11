class UserMultiRatingsController < ApplicationController
  
  before_filter :authenticate_account!

  def create
    @rater_user = User.find(params[:user_multi_rating][:rater_id]) or not_found
    @rated_user = User.find(params[:user_multi_rating][:rated_id]) or not_found
    if params[:user_multi_rating][:score]
      params[:user_multi_rating][:score].each do |code, score|
        @rater_user.user_multi_ratings.create!(aspect_code: code, score: score, rated: @rated_user)
      end
    end
    respond_to do |format|
      format.html { redirect_to user_report_ratings_path(@rated_user) }
      format.js do
        @rated_user = @rated_user.reload
        @aspect_scores = @rated_user.multi_ratings_by_users.current_period.group(:aspect_code).select('aspect_code, avg(score) AS aspect_score')
      end
    end
  end
end