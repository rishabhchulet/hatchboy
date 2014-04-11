module Hatchboy
  module ReportsFilters
    class WorkLogsFilter

      attr_reader :scope

      delegate :all, :to_a, :find_each, :first, :inspect, :[], :includes, :count, :to => :scope

      def initialize scope = WorkLog
        @scope = scope
      end

      def filter_by_params params
        if params[:date] and params[:date] != 'all_time'
          @scope = case params[:date]
            when 'today' then @scope.where("work_logs.created_at > ?", Time.now.beginning_of_day)
            when 'last_week' then @scope.where("work_logs.created_at > ?", 1.week.ago.beginning_of_day)
            when 'last_month' then @scope.where("work_logs.created_at > ?", 1.month.ago.beginning_of_day) 
            when 'specific' then @scope.where("DATE(work_logs.created_at) = ?", DateTime.parse(params[:specific_date]))
            when 'period' then @scope.where("DATE(work_logs.created_at) BETWEEN ? AND ?", DateTime.parse(params[:period_from]), DateTime.parse(params[:period_to]))
          end
        end
        @scope = @scope.where(user_id: params[:users]) if params[:group_by] == "users" and params[:users]
        @scope = @scope.where(team_id: params[:teams]) if params[:group_by] == "teams" and params[:teams]
        self.class.new @scope
      end

      def with_group_by_hours
        self.class.new @scope.select("DATE_TRUNC('hour', work_logs.created_at) AS created_at").group("created_at").order("created_at")
      end

      def with_group_by_day
        self.class.new @scope.select("DATE_TRUNC('day', work_logs.created_at) AS created_at").group("created_at").order("created_at")
      end

      def with_group_by_mounth
        self.class.new @scope.select("DATE_TRUNC('month', work_logs.created_at) AS created_at").group("created_at").order("created_at")
      end

      def with_summ_time
        self.class.new @scope.select("sum(time) AS time")
      end

      def with_group_by_users
        self.class.new @scope.includes(:user).group(:user_id).select(:user_id)
      end

      def with_group_by_teams
        self.class.new @scope.includes(:team, :user).group(:team_id, :user_id).select(:team_id, :user_id)
      end
    end
  end
end