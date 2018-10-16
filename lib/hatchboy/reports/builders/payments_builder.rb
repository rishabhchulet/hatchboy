module Hatchboy
  module Reports
    module Builders
      class PaymentsBuilder < Hatchboy::Reports::Builder

        include ReportsHelper
        
        AVAILABLE_PARAMS = [:date, :users, :specific_date, :period_from, :period_to]
        
        attr_reader :users, :users_payments

        def init_filter
          scope = @company ? PaymentRecipient.joins(:payment).where('payments.company_id = ?', company.id) : PaymentRecipient
          @filter = Hatchboy::Reports::Filters::PaymentsFilter.new(scope).with_statuses([Payment::STATUS_SENT, Payment::STATUS_MARKED]).filter_by_params(@params).includes(:user)
        end

        def build_report_data params = {}
          init_filter if @filter.nil?
          payments = @filter.to_a
          @users_payments = payments.group_by(&:user_id)
          @users = payments.map(&:user).uniq.sort_by{|u| -@users_payments[u.id].map(&:amount).reduce(:+)}
          build_report_chart payments if params[:chart] and payments.count > 0
        end

        private 
          
          def build_report_chart payments
            chart_data = group_timeline_from_params payments, @params do |scope, date|
              @users.collect do |user|
                payment = scope.select{|p| user.id == p.user_id}.first if scope
                { id: user.id, name: user.name, value: payment ? payment.amount.round(2) : 0}
              end
            end
            @chart = build_chart({title: "Payments sent to users for #{report_title_from_params(@params)}", y_title: "$", data: chart_data})
          end

      end
    end
  end
end