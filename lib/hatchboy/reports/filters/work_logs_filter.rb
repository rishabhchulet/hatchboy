module Hatchboy
  module Reports
    module Filters
      class WorkLogsFilter

        include ReportsHelper
        
        attr_reader :scope

        delegate :all, :to_a, :find_each, :first, :inspect, :[], :includes, :count, :preload, :to => :scope

        def initialize scope = WorkLog
          @scope = scope
        end

        def filter_by_params params
          scope = self.class.new @scope.select("sum(time) AS time")
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
          scope = scope.with_users(params[:users]) if (params[:group_by] == "users" or params[:group_by].blank?) and params[:users]
          scope = scope.with_teams(params[:teams]) if params[:group_by] == "teams" and params[:teams]
          params[:group_by] == "teams" ? scope.group_by_teams : scope.group_by_users
        end

        def from_date date
          self.class.new @scope.where("work_logs.on_date > ?", date)
        end

        def in_date date
          self.class.new @scope.where("DATE(work_logs.on_date) = ?", date)
        end

        def in_date_range from, to
          self.class.new @scope.where("DATE(work_logs.on_date) BETWEEN ? AND ?", from, to)
        end
        
        def with_users users
          self.class.new @scope.where(user_id: users)
        end

        def with_teams teams
          self.class.new @scope.where(team_id: teams)
        end

        def group_by_date_field field 
          self.class.new @scope.select("DATE_TRUNC('#{field}', work_logs.on_date) AS g_created_at").group("g_created_at").order("g_created_at")
        end

        def group_by_users
          self.class.new @scope.group(:user_id).select(:user_id)
        end

        def group_by_teams
          self.class.new @scope.group(:team_id, :user_id).select(:team_id, :user_id)
        end
      end
    end
  end
end