module Hatchboy
  module Reports
    module Builders
      class RatingsBuilder < Hatchboy::Reports::Builder
        
        include ReportsHelper
        
        attr_reader :users

        def build_report_data params = {}
          @users = @company ? @company.users.order("rating DESC") : User.order("rating DESC")
          build_report_chart if params[:chart]
        end

        private

          def build_report_chart
            scores = UserAvgRating.where(rated_id: @users).group(:date_period, :rated_id).order(:date_period).select('rated_id, date_period, avg(avg_score) AS rating')
            chart_data = Hash.new
            scores.group_by(&:date_period).each do |date, date_scores|
              chart_data[date.to_date.strftime("%B %Y")] = date_scores.map{|s| {id: s.rated_id, name: @users.select{|user| user.id == s.rated_id}.first.name, value: s.rating.round(2)}}
            end
            @chart = build_chart({title: "360* ratings", y_title: "Rating value", data: chart_data, without_average: true, columns: true}) if chart_data.length > 0
          end

      end
    end
  end
end