class ReportHoursController < ApplicationController
  
  before_filter :check_session!

  include ReportsHelper

  def team
    @team = account_company.teams.where(id: params[:team_id]).first or not_found
    query_params = retrieve_query_params :hours, [:date, :specific_date, :period_from, :period_to]
    worklogs = Hatchboy::Reports::Filters::WorkLogsFilter.new(WorkLog.where(team_id: @team.id)).filter_by_params(query_params).includes(:user).to_a

    @team_users = worklogs.map(&:user).uniq
    @team_users_worklogs = worklogs.group_by{|w| w.user_id}

    chart_data = group_timeline_from_params worklogs, query_params do |scope, date|
      @team_users.collect do |user|
        worklog = scope.select{|w| user.id == w.user_id}.first if scope
        { id: user.id, name: user.name, value: worklog ? worklog.time : 0 }
      end
    end

    @chart = build_chart({title: "#{@team.name} work logs for #{report_title_from_params(query_params)}", y_title: "Hours", data: chart_data})
  end

  def user
    @user = account_company.users.where(id: params[:user_id]).first or not_found
    query_params = retrieve_query_params :hours, [:date, :specific_date, :period_from, :period_to]
    query_params[:group_by] = "teams"
    worklogs = Hatchboy::Reports::Filters::WorkLogsFilter.new(WorkLog.where(user_id: @user.id)).filter_by_params(query_params).includes(:team).to_a

    @user_teams = worklogs.map(&:team).uniq
    @user_teams_worklogs = worklogs.group_by{|w| w.team_id}
    
    chart_data = group_timeline_from_params worklogs, query_params do |scope, date|
      @user_teams.collect do |team|
        worklog = scope.select{|w| team.id == w.team_id}.first if scope
        { id: team.id, name: team.name, value: worklog ? worklog.time : 0 }
      end
    end

    @chart = build_chart({title: "#{@user.name} work logs for #{report_title_from_params(query_params)}", y_title: "Hours", data: chart_data})
  end
end