class ReportRatingsController < ApplicationController
  
  before_filter :check_session!

  include ReportsHelper

  def index
    @users = User.order("rating DESC").page(params[:page]).per(20)
    scores = UserAvgRating.where(rated_id: @users).group(:date_period, :rated_id).order(:date_period).select('rated_id, date_period, avg(avg_score) AS rating')
    chart_data = Hash.new
    scores.group_by(&:date_period).each do |date, date_scores|
      chart_data[date.to_date] = date_scores.map{|s| {id: s.rated_id, name: @users.select{|user| user.id == s.rated_id}.first.name, value: s.rating.round(2)}}
    end
    @chart = build_chart({title: "Users rating", y_title: "Rating value", data: chart_data, without_average: true, columns: true}) if chart_data.length > 0
  end

  def user
    @user = User.find(params[:user_id]) or not_found
    @current_user_scores = current_account.user.user_multi_ratings.current_period.where(rated: @user).all.group_by(&:aspect_code)
    @aspect_scores = @user.multi_ratings_by_users.current_period.group(:aspect_code).select('aspect_code, avg(score) AS aspect_score')
    scores = UserAvgRating.where(rated: @user).group(:date_period).order(:date_period).select('date_period, avg(avg_score) AS rating')
    if scores.length > 1
      @chart = LazyHighCharts::HighChart.new('graph') do |f|
        f.title({ :text=>"Rating of #{@user.name}"})
        f.options[:xAxis][:categories] = scores.map(&:date_period)
        f.options[:chart][:zoomType] = 'x,y'
        f.series(:type=> 'spline',:name=> 'Rating', :data=> scores.map(&:rating).collect{|score| score.round(2)})
        f.yAxis [{:title => {:text => "Rating value", :margin => 10}, :min => 0, :max => UserMultiRating::MAX_RATING},]
      end
    end
  end
end