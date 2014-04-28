module Hatchboy
  module Reports
    module Builders
      class HoursBuilder

        include ReportsHelper

        AVAILABLE_PARAMS = [:date, :group_by, :users, :teams, :specific_date, :period_from, :period_to]
        
        attr_reader :params, :chart, :teams, :users, :teams_users, :users_worklogs

        def initialize params
          @params = params
          worklogs = Hatchboy::Reports::Filters::WorkLogsFilter.new.filter_by_params(@params)

          if @params[:group_by] == "teams"
            worklogs = worklogs.includes(:team, :user).to_a
            @teams_users = worklogs.group_by{|w| w.team.id}
            @teams = worklogs.map(&:team).uniq.sort_by{|t| -@teams_users[t.id].map(&:time).reduce(:+)}
          else
            worklogs = worklogs.includes(:user).to_a
            @users_worklogs = worklogs.group_by{|w| w.user_id}
            @users = worklogs.map(&:user).uniq.sort_by{|u| -@users_worklogs[u.id].map(&:time).reduce(:+)}
          end

          build_chart_object(worklogs) if worklogs.count > 0
        end

        def build_chart_object worklogs
          chart_data = group_timeline_from_params worklogs, @params do |scope, date|
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