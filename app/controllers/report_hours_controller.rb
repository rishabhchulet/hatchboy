class ReportHoursController < ApplicationController
  
  before_filter :check_session!

  include ReportsHelper

  def index
    params[:group_by] ||= "users"
    params[:date] ||= "all_time"

    worklogs = Hatchboy::ReportsFilters::WorkLogsFilter.new
    worklogs = worklogs.filter_by_params(params)
    if params[:group_by] == "teams"
      worklogs = worklogs.includes(:team, :user).to_a
      @teams_users = worklogs.group_by{|w| w.team.id}
      @teams = worklogs.map(&:team).uniq
    else
      worklogs = worklogs.includes(:user).to_a
      @users_worklogs = worklogs.group_by{|w| w.user_id}
      @users = worklogs.map(&:user).uniq
    end

    if worklogs.count > 0
      chart_data = group_timeline_from_params worklogs, params do |scope, date|
        if params[:group_by] == "teams"
          @teams.collect do |team|
            worklog = scope.select{|w| team.id == w.team_id}.first if scope
            { time: worklog ? (worklog.time/3600).round(4) : 0, team: team }
          end
        else
          @users.collect do |user|
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