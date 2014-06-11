module Hatchboy
  module Reports
    module Builders
      class RatingsBuilder < Hatchboy::Reports::Builder
        
        include ReportsHelper
        
        attr_reader :users

        AVAILABLE_PARAMS = [:date, :period_from, :period_to]

        def build_report_data params = {}
          @users = @company ? @company.users.order("rating DESC") : User.order("rating DESC")
          build_report_chart if params[:chart]
        end

        private

          def build_report_chart
            scores = UserAvgRating.where(rated_id: @users).select('rated_id, date_period AS g_created_at, avg(avg_score) AS rating').group('g_created_at, rated_id').order('g_created_at')
            scores = @params[:date] == 'period' ? scores.where(date_period: @params[:period_from]..@params[:period_to]).to_a : scores.to_a

            if scores.count > 0
              chart_data = group_timeline_from_params scores, {} do |scope, date|
                @users.collect do |user|
                  score = scope.select{|s| user.id == s.rated_id}.first if scope
                  { id: user.id, name: user.name, value: score ? score.rating.round(2) : 0}
                end
              end
              
              @chart = build_chart({title: "360* ratings", y_title: "Rating value", data: chart_data, without_average: true, columns: true}) if chart_data.length > 0
            end
          end

      end
    end
  end
end