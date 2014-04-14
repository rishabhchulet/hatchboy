module Hatchboy
  module ReportsFilters
    class WorkLogsFilter

      attr_reader :scope

      delegate :all, :to_a, :find_each, :first, :inspect, :[], :includes, :count, :to => :scope

      def initialize scope = WorkLog
        @scope = scope
      end

      def filter_by_params params
        filter_scope = self.class.new case params[:date]
          when 'today' then @scope.where("work_logs.created_at > ?", Time.now.beginning_of_day)
          when 'last_week' then @scope.where("work_logs.created_at > ?", 1.week.ago.beginning_of_day)
          when 'last_month' then @scope.where("work_logs.created_at > ?", 1.month.ago.beginning_of_day) 
          when 'specific' then @scope.where("DATE(work_logs.created_at) = ?", DateTime.parse(params[:specific_date]))
          when 'period' then @scope.where("DATE(work_logs.created_at) BETWEEN ? AND ?", DateTime.parse(params[:period_from]), DateTime.parse(params[:period_to]))
          else @scope
        end
        filter_scope = filter_scope.with_users(params[:users]) if params[:group_by] == "users" and params[:users]
        filter_scope = filter_scope.with_teams(params[:teams]) if params[:group_by] == "teams" and params[:teams]
        params[:group_by] == "teams" ? filter_scope.with_group_by_teams : filter_scope.with_group_by_users
      end

      def with_users users
        self.class.new @scope.where(user_id: users)
      end

      def with_teams teams
        self.class.new @scope.where(team_id: teams)
      end

      def with_group_by_hours
        self.class.new @scope.select("DATE_TRUNC('hour', work_logs.created_at) AS g_created_at").group("g_created_at").order("g_created_at")
      end

      def with_group_by_day
        self.class.new @scope.select("DATE_TRUNC('day', work_logs.created_at) AS g_created_at").group("g_created_at").order("g_created_at")
      end

      def with_group_by_mounth
        self.class.new @scope.select("DATE_TRUNC('month', work_logs.created_at) AS g_created_at").group("g_created_at").order("g_created_at")
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