module Hatchboy
  module Reports
    module Builders
      class MvpBuilder

        include ReportsHelper
        
        AVAILABLE_PARAMS = [:date, :users, :period_from, :period_to]
        
        attr_reader :params, :chart, :users, :scores

        def initialize params
          @params = params
          payments = Hatchboy::Reports::Filters::PaymentsFilter.new.with_sended_payments.filter_by_params(@params).includes(:user).to_a
          worklogs = Hatchboy::Reports::Filters::WorkLogsFilter.new.filter_by_params(@params).to_a
          @users = payments.map(&:user).uniq

          @scores = []
          payments.group_by(&:user_id).each do |user_id, user_payments|
            user_amount = user_payments.map(&:amount).reduce(:+)
            user_time = worklogs.select{|w| w.user_id == user_id}.map(&:time).reduce(:+)
            if user_time and user_amount
              @scores << {
                rate: (user_time / user_amount).round(4),
                user: user_payments.first.user
              }
            end
          end
          
          build_chart_object(payments, worklogs) if @scores.count > 0
        end

        def build_chart_object payments, worklogs
          worklogs = worklogs.group_by{|w| w.g_created_at.to_date.at_beginning_of_month}
          chart_data = group_timeline_from_params payments, {date: "all_time"} do |scope, date|
            @users.collect do |user|
              payment = scope.select{|p| user.id == p.user_id}.first if scope
              worklog = worklogs[date].select{|p| user.id == p.user_id}.first if worklogs[date]
              { id: user.id, name: user.name, value: payment ? ((worklog ? worklog.time : 0) / payment.amount).round(2) : 0}
            end
          end

          chart_data = chart_data.inject({}) do |h, (date, date_scores)|
            max_period_score = date_scores.map{|s| s[:value]}.max
            h[date] = date_scores.map{|s| s[:value] = 100 - ((max_period_score - s[:value]) / max_period_score * 100).round; s} if max_period_score > 0
            h
          end
          chart_data[chart_data.keys.first] = chart_data[chart_data.keys.first].sort_by{|s| -s[:value]} if chart_data.length == 1
          @chart = build_chart({title: "MVP", y_title: "%", data: chart_data, without_average: true, innerSize: "50%"})
        end
      end
    end
  end
end