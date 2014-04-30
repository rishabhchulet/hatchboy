module Hatchboy
  module Reports
    module Filters
      class PaymentsFilter

        include ReportsHelper
        
        attr_reader :scope

        delegate :all, :to_a, :find_each, :first, :inspect, :[], :includes, :count, :to => :scope

        def initialize scope = PaymentRecipient
          @scope = scope
        end

        def filter_by_params params
          scope = self.class.new @scope.joins(:payment).group(:user_id).select("sum(amount) AS amount", :user_id)
          scope = case params[:date]
            when 'today' then scope.group_by_date_field("hour").in_date(Time.now)
            when 'last_week' then scope.group_by_date_field("day").in_date_range(1.week.ago.beginning_of_day, Date.today)
            when 'last_month' then scope.group_by_date_field("day").in_date_range(1.month.ago.beginning_of_day, Date.today)
            when 'specific' then scope.group_by_date_field("hour").in_date(parse_date(params[:specific_date]))
            when 'period'
              scope = scope.group_by_date_field((parse_date(params[:period_to]) - parse_date(params[:period_from])).to_i > 90 ? "month" : "day")
              scope.in_date_range(parse_date(params[:period_from]), parse_date(params[:period_to]))
            else scope.group_by_date_field("month")
          end
          scope = scope.with_users(params[:users]) if params[:users]
          scope
        end

        def from_date date
          self.class.new @scope.where("payments.created_at > ?", date)
        end

        def in_date date
          self.class.new @scope.where("DATE(payments.created_at) = ?", date)
        end

        def in_date_range from, to
          self.class.new @scope.where("DATE(payments.created_at) BETWEEN ? AND ?", from, to)
        end

        def with_users users
          self.class.new @scope.where(user_id: users)
        end

        def with_sended_payments
          self.class.new @scope.joins(:payment).where("payments.status = ?", Payment::STATUS_SENT)
        end

        def group_by_date_field field 
          self.class.new @scope.select("DATE_TRUNC('#{field}', payments.created_at) AS g_created_at").group("g_created_at").order("g_created_at")
        end
      end
    end
  end
end