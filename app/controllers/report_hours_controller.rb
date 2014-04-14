class ReportHoursController < ApplicationController
  
  before_filter :check_session!

  include ReportsHelper

  def index
    params[:group_by] ||= "users"
    params[:date] ||= "all_time"

    worklogs = Hatchboy::ReportsFilters::WorkLogsFilter.new.with_summ_time
    worklogs = worklogs.filter_by_params(params)
    
    if params[:group_by] == "teams"
      list = worklogs.to_a
      @teams = list.map(&:team).uniq{|team| team.id}.sort{|team| team.created_at.to_date}
      @teams_users = list.group_by{|w| w.team.id}
    else
      @users = worklogs.to_a
    end

    chart_data = group_scope_from_params worklogs, params do |scope, date|
      if params[:group_by] == "teams"
        @teams.collect do |team|
          worklog = scope.select{|w| team.id == w.team_id}.first if scope
          { time: worklog ? (worklog.time/3600).round(4) : 0, team: team }
        end
      else
        @users.map(&:user).uniq.collect do |user|
          worklog = scope.select{|w| user.id == w.user_id}.first if scope
          { time: worklog ? (worklog.time/3600).round(4) : 0, user: user }
        end
      end
    end

    @chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.title({ :text=>"Work Logs"})
      f.options[:xAxis][:categories] = chart_data.keys
      f.options[:chart][:zoomType] = 'x,y'
      
      if params[:group_by] == "teams"
        chart_data.values.flatten.group_by{|u| u[:team].id}.each do |team_id, team|
          f.series(:type=> 'column',:name=> team.first[:team].name,:data=> team.map{|d| d[:time]})
        end
      else
        chart_data.values.flatten.group_by{|u| u[:user].id}.each do |user_id, user|
          f.series(:type=> 'column',:name=> user.first[:user].name,:data=> user.map{|d| d[:time]})
        end
      end

      f.series(:type=> 'spline',:name=> 'Average', :data=> chart_data.values.collect{|w| w.map{|e| e[:time]}.instance_eval { (reduce(:+) / size.to_f).round(2) } })
      f.yAxis [
        {:title => {:text => "Hours", :margin => 10}, :min => 0},
      ]
      f.legend(:align => 'right', :verticalAlign => 'top', :y => 75, :x => -50, :layout => 'vertical')
    end
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