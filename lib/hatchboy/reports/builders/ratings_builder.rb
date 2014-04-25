module Hatchboy
  module Reports
    module Builders
      class RatingsBuilder
        
        include ReportsHelper
        
        attr_reader :params, :chart, :users, :users_payments

        def initialize params
          @params = params
          @users = User.order("rating DESC")
          build_chart_object
        end

        def build_chart_object
          scores = UserAvgRating.where(rated_id: @users).group(:date_period, :rated_id).order(:date_period).select('rated_id, date_period, avg(avg_score) AS rating')
          chart_data = Hash.new
          scores.group_by(&:date_period).each do |date, date_scores|
            chart_data[date.to_date] = date_scores.map{|s| {id: s.rated_id, name: @users.select{|user| user.id == s.rated_id}.first.name, value: s.rating.round(2)}}
          end
          @chart = build_chart({title: "Users rating", y_title: "Rating value", data: chart_data, without_average: true, columns: true}) if chart_data.length > 0
        end
      end
    end
  end
end