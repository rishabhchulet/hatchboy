module Hatchboy
  module Reports
    module Builders
      class HoursBuilder < Hatchboy::Reports::Builder

        include ReportsHelper

        AVAILABLE_PARAMS = [:date, :group_by, :users, :teams, :specific_date, :period_from, :period_to]
        
        attr_reader :teams, :users, :teams_users, :users_worklogs

        def init_filter
          @filter = Hatchboy::Reports::Filters::WorkLogsFilter.new.filter_by_params(@params)
          @filter = @filter.with_teams(company.teams) if @company and @params[:group_by] == "teams"
          @filter = @filter.with_users(company.users) if @company and (@params[:group_by] == "users" or @params[:group_by].blank?)
          @filter = @params[:group_by] == "teams" ? @filter.preload(:team, :user) : @filter.preload(:user)
        end

        def build_report_data params = {}
          init_filter if @filter.nil?
          worklogs = @filter.to_a
          if @params[:group_by] == "teams"
            @teams_users = worklogs.group_by{|w| w.team.id}
            @teams = worklogs.map(&:team).uniq.sort_by{|t| -@teams_users[t.id].map(&:time).reduce(:+)}
          else
            @users_worklogs = worklogs.group_by{|w| w.user_id}
            @users = worklogs.map(&:user).uniq.sort_by{|u| -@users_worklogs[u.id].map(&:time).reduce(:+)}
          end
          build_report_chart worklogs if params[:chart] and worklogs.count > 0
        end

        private

          def build_report_chart worklogs
            chart_data = group_timeline_from_params @filter.to_a, @params do |scope, date|
              if @params[:group_by] == "teams"
                @teams.collect do |team|
                  team_worklogs = scope.select{|w| team.id == w.team_id} if scope
                  { id: team.id, name: team.name, value: ((team_worklogs and team_worklogs.count > 0) ? team_worklogs.map(&:time).reduce(:+) : 0) }
                end
              else
                @users.collect do |user|
                  worklog = scope.select{|w| user.id == w.user_id}.first if scope
                  { id: user.id, name: user.name, value: worklog ? worklog.time : 0 }
                end
              end
            end
            @chart = build_chart({title: "Work Logs", y_title: "Hours", data: chart_data})
          end

      end
    end
  end
end