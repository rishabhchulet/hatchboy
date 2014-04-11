class ReportHoursController < ApplicationController
  
  before_filter :check_session!

  include ReportsHelper

  def index
    params[:group_by] ||= "users"
    params[:date] ||= "all_time"

    worklogs = Hatchboy::ReportsFilters::WorkLogsFilter.new.with_summ_time
    worklogs = worklogs.filter_by_params(params)
    
    if params[:group_by] == "teams"
      list = worklogs.with_group_by_teams.to_a
      @teams = list.map(&:team).uniq{|team| team.id}.sort{|team| team.created_at.to_date}
      @teams_users = list.group_by{|w| w.team.id}
    else
      @users = worklogs.with_group_by_users.to_a
    end

    chart_data = prepare_chart_data_scope worklogs, params do |data_scope, date|
      workflow = (date.is_a? Integer) ? data_scope.select{|w| w.created_at.to_time.hour == date}.first : data_scope.select{|w| w.created_at.to_time == date}.first
      if workflow
        (workflow.time/3600).round(4)
      end
    end
    @chart = build_chart_object("Tracked time","Hours",chart_data)
      
  rescue Exception => e
    flash.now[:error] = e.message
    render :index
  end

  def team
    @team = Team.where(id: params[:team_id]).first or not_found
    @worklogs = @team.worklogs.group(:user_id).select("work_logs.user_id, sum(work_logs.time) AS time")
  end

  def user
    @user = User.where(id: params[:user_id]).first or not_found
    @worklogs = WorkLog.includes(:team, :user).where(user_id: params[:user_id]).page params[:page]
  end
end