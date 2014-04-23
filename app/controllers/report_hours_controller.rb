class ReportHoursController < ApplicationController
  
  before_filter :check_session!

  include ReportsHelper

  def index
    @query_params = retrieve_query_params :hours, [:date, :group_by, :users, :teams, :specific_date, :period_from, :period_to]
    worklogs = Hatchboy::ReportsFilters::WorkLogsFilter.new.filter_by_params(@query_params)

    if @query_params[:group_by] == "teams"
      worklogs = worklogs.includes(:team, :user).to_a
      @teams_users = worklogs.group_by{|w| w.team.id}
      @teams = worklogs.map(&:team).uniq.sort_by{|t| -@teams_users[t.id].map(&:time).reduce(:+)}
    else
      worklogs = worklogs.includes(:user).to_a
      @users_worklogs = worklogs.group_by{|w| w.user_id}
      @users = worklogs.map(&:user).uniq.sort_by{|u| -@users_worklogs[u.id].map(&:time).reduce(:+)}
    end

    if worklogs.count > 0
      chart_data = group_timeline_from_params worklogs, @query_params do |scope, date|
        if @query_params[:group_by] == "teams"
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
  rescue Exception => e
    flash.now[:error] = e.message
    render :index
  end

  def team
    @team = Team.where(id: params[:team_id]).first or not_found
    query_params = retrieve_query_params :hours, [:date, :specific_date, :period_from, :period_to]
    worklogs = Hatchboy::ReportsFilters::WorkLogsFilter.new(WorkLog.where(team_id: @team.id)).filter_by_params(query_params).includes(:user).to_a

    @team_users = worklogs.map(&:user).uniq
    @team_users_worklogs = worklogs.group_by{|w| w.user_id}

    chart_data = group_timeline_from_params worklogs, query_params do |scope, date|
      @team_users.collect do |user|
        worklog = scope.select{|w| user.id == w.user_id}.first if scope
        { id: user.id, name: user.name, value: worklog ? worklog.time : 0 }
      end
    end

    @chart = build_chart({title: "Work Logs of #{@team.name}", y_title: "Hours", data: chart_data})
  end

  def user
    @user = User.where(id: params[:user_id]).first or not_found
    query_params = retrieve_query_params :hours, [:date, :specific_date, :period_from, :period_to]
    query_params[:group_by] = "teams"
    worklogs = Hatchboy::ReportsFilters::WorkLogsFilter.new(WorkLog.where(user_id: @user.id)).filter_by_params(query_params).includes(:team).to_a

    @user_teams = worklogs.map(&:team).uniq
    @user_teams_worklogs = worklogs.group_by{|w| w.team_id}
    
    chart_data = group_timeline_from_params worklogs, query_params do |scope, date|
      @user_teams.collect do |team|
        worklog = scope.select{|w| team.id == w.team_id}.first if scope
        { id: team.id, name: team.name, value: worklog ? worklog.time : 0 }
      end
    end

    @chart = build_chart({title: "Work Logs of #{@user.name}", y_title: "Hours", data: chart_data})
  end
end