module Hatchboy
  module Reports
    module Builders
      class PaymentsBuilder

        include ReportsHelper
        
        AVAILABLE_PARAMS = [:date, :users, :specific_date, :period_from, :period_to]
        
        attr_reader :params, :chart, :users, :users_payments

        def initialize company, params
          @params = params
          payments = Hatchboy::Reports::Filters::PaymentsFilter.new(PaymentRecipient.joins(:payment).where('payments.company_id = ?', company.id)).with_sended_payments.filter_by_params(@params).includes(:user).to_a

          @users_payments = payments.group_by(&:user_id)
          @users = payments.map(&:user).uniq.sort_by{|u| -@users_payments[u.id].map(&:amount).reduce(:+)}

          build_chart_object(payments) if payments.count > 0
        end

        def build_chart_object payments
          chart_data = group_timeline_from_params payments, @params do |scope, date|
            @users.collect do |user|
              payment = scope.select{|p| user.id == p.user_id}.first if scope
              { id: user.id, name: user.name, value: payment ? payment.amount.round(2) : 0}
            end
          end
          @chart = build_chart({title: "Payments", y_title: "$", data: chart_data})
        end
      end
    end
  end
end