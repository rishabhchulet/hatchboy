module Hatchboy
  module ReportsFilters
    class PaymentsFilter

      attr_reader :scope

      delegate :all, :to_a, :find_each, :first, :inspect, :[], :includes, :count, :to => :scope

      def initialize scope = PaymentRecipient
        @scope = scope
      end

      def filter_by_params params
        if params[:date] and params[:date] != 'all_time'
          @scope = @scope.joins(:payment)
          @scope = case params[:date]
            when 'today' then @scope.where("payments.created_at > ?", Time.now.beginning_of_day)
            when 'last_week' then @scope.where("payments.created_at > ?", 1.week.ago.beginning_of_day)
            when 'last_month' then @scope.where("payments.created_at > ?", 1.month.ago.beginning_of_day) 
            when 'specific' then @scope.where("DATE(payments.created_at) = ?", DateTime.parse(params[:specific_date]))
            when 'period' then @scope.where("DATE(payments.created_at) BETWEEN ? AND ?", DateTime.parse(params[:period_from]), DateTime.parse(params[:period_to]))
          end
        end
        @scope = @scope.where(user_id: params[:users]) if params[:users]
        self.class.new @scope
      end

      def with_sended_payments
        self.class.new @scope.joins(:payment).where("payments.status = ?", Payment::STATUS_SENT)
      end

      def with_group_by_hours
        self.class.new @scope.joins(:payment).select("DATE_TRUNC('hour', payments.created_at) AS created_at").group("created_at").order("created_at")
      end

      def with_group_by_day
        self.class.new @scope.joins(:payment).select("DATE_TRUNC('day', payments.created_at) AS created_at").group("created_at").order("created_at")
      end

      def with_group_by_mounth
        self.class.new @scope.joins(:payment).select("DATE_TRUNC('month', payments.created_at) AS created_at").group("created_at").order("created_at")
      end

      def with_summ_amount
        self.class.new @scope.select("sum(amount) AS amount")
      end

      def with_group_by_users
        self.class.new @scope.group(:user_id).select(:user_id)
      end
    end
  end
end