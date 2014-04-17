class ReportMvpController < ApplicationController
  
  before_filter :check_session!

  include ReportsHelper

  def index
    params[:date] ||= "all_time"
    payments = Hatchboy::ReportsFilters::PaymentsFilter.new.with_sended_payments.filter_by_params(params).includes(:user).to_a
    worklogs = Hatchboy::ReportsFilters::WorkLogsFilter.new.filter_by_params(params).to_a
    @users = payments.map(&:user).uniq

    @scores = []
    payments.group_by(&:user_id).each do |user_id, user_payments|
      user_amount = user_payments.map(&:amount).reduce(:+)
      user_time = worklogs.select{|w| w.user_id == user_id}.map(&:time).reduce(:+)
      if user_time and user_amount
        @scores << {
          rate: (user_time / user_amount).round(4),
          user: user_payments.first.user
        }
      end
    end

    if payments.count > 0
      worklogs = (params[:date] == "today" or params[:date] == "specific") ? worklogs.group_by{|w| w.g_created_at.to_time} : worklogs.group_by{|w| w.g_created_at.to_date}
      chart_data = group_timeline_from_params payments, params do |scope, date|
        period_worklogs = (date.is_a? Integer) ? worklogs[Time.at(date)] : worklogs[date]
        @users.collect do |user|
          payment = scope.select{|p| user.id == p.user_id}.first if scope
          worklog = period_worklogs.select{|p| user.id == p.user_id}.first if period_worklogs
          { rate: payment ? ((worklog ? worklog.time : 0) / payment.amount).round(2) : 0, user: user }
        end
      end

      @chart = LazyHighCharts::HighChart.new('graph') do |f|
        f.title({ :text=>"MVP"})
        f.options[:xAxis][:categories] = chart_data.keys
        f.options[:chart][:zoomType] = 'x,y'
        chart_data.values.flatten.group_by{|u| u[:user].id}.each do |id, user|
          f.series(:type=> 'column',:name=> user.first[:user].name,:data=> user.map{|d| d[:rate]})
        end
        f.series(:type=> 'spline',:name=> 'Average', :data=> chart_data.values.collect{|w| w.map{|e| e[:rate]}.instance_eval { (reduce(:+) / size.to_f).round(2) } })
        f.yAxis [ {:title => {:margin => 10}, :min => 0} ]
        f.legend(:align => 'right', :verticalAlign => 'top', :y => 75, :x => -50, :layout => 'vertical')
      end
    end
  rescue Exception => e
    flash.now[:error] = e.message
    render :index
  end

  def user
    @user = User.where(id: params[:user_id]).first or not_found
    params[:date] = "all_time"
    params[:users] = @user.id
    params[:group_by] = "users"
    payments = Hatchboy::ReportsFilters::PaymentsFilter.new.with_sended_payments.filter_by_params(params).to_a
    worklogs = Hatchboy::ReportsFilters::WorkLogsFilter.new.filter_by_params(params).to_a
    
    @scores = []
    payments.each do |payment|
      worklog = worklogs.select{|w| w.g_created_at == payment.g_created_at}.first
      if worklog
        @scores << {
          rate: (worklog.time / payment.amount).round(4),
          date: payment.g_created_at.to_date
        }
      end
    end

    if @scores.count > 0
      @chart = LazyHighCharts::HighChart.new('graph') do |f|
        f.title({ :text=>"MVP"})
        f.options[:xAxis][:categories] = @scores.map{|s| s[:date]}
        f.options[:chart][:zoomType] = 'x,y'
        f.series(:type=> 'column',:name=> @user.name,:data=> @scores.map{|s| s[:rate]})
        f.yAxis [ {:title => {:margin => 10}, :min => 0} ]
      end
    end
  end
end