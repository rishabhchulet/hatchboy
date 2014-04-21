class ReportRatingsController < ApplicationController
  
  before_filter :check_session!

  def index
    @users = User.order(:rating).page(params[:page]).per(20)
    scores = UserAvgRating.where(rated_id: @users).group(:date_period, :rated_id).order(:date_period).select('rated_id, date_period, avg(avg_score) AS rating')
    if scores.length > 1
      @chart = LazyHighCharts::HighChart.new('graph') do |f|
        f.title({ :text=>"Users rating"})
        f.options[:chart][:zoomType] = 'x,y'
        f.options[:xAxis][:categories] = scores.map(&:date_period).uniq
        scores.group_by(&:rated_id).each do |rated_id, scores|
          f.series(:type=> 'column',:name=> @users.select{|user| user.id == rated_id}.first.name,:data=> scores.map(&:rating).collect{|r| r.round(2)})
        end
        f.series(:type=> 'spline',:name=> 'Average', :data=> scores.group_by(&:date_period).map{|key, scores| scores.map(&:rating).instance_eval { (reduce(:+) / size.to_f).round(2) } })
        f.yAxis [
          {:title => {:text => "Rating value", :margin => 10}, :min => 0, :max => UserMultiRating::MAX_RATING},
        ]
        f.legend(:align => 'right', :verticalAlign => 'top', :y => 75, :x => -50, :layout => 'vertical')
      end
    end
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
        f.yAxis [
          {:title => {:text => "Rating value", :margin => 10}, :min => 0, :max => UserMultiRating::MAX_RATING},
        ]    
      end
    end
  end
end