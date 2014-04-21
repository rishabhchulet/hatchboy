class ReportMvpController < ApplicationController
  
  before_filter :check_session!

  include ReportsHelper

  def index
    @query_params = retrieve_query_params :mvp, [:date, :users, :period_from, :period_to]
    payments = Hatchboy::ReportsFilters::PaymentsFilter.new.with_sended_payments.filter_by_params(@query_params).includes(:user).to_a
    worklogs = Hatchboy::ReportsFilters::WorkLogsFilter.new.filter_by_params(@query_params).to_a
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

    if @scores.count > 0
      worklogs = worklogs.group_by{|w| w.g_created_at.to_date.at_beginning_of_month}
      chart_data = group_timeline_from_params payments, {date: "all_time"} do |scope, date|
        @users.collect do |user|
          payment = scope.select{|p| user.id == p.user_id}.first if scope
          worklog = worklogs[date].select{|p| user.id == p.user_id}.first if worklogs[date]
          { id: user.id, name: user.name, value: payment ? ((worklog ? worklog.time : 0) / payment.amount).round(2) : 0}
        end
      end

      @chart = build_chart({title: "MVP", y_title: "Rate", data: chart_data}) if chart_data.length > 0
    end
  rescue Exception => e
    flash.now[:error] = e.message
    render :index
  end

  def user
    @user = User.where(id: params[:user_id]).first or not_found
    params[:date] = "all_time"
    params[:users] = @user.id
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

    if @scores.count > 1
      @chart = LazyHighCharts::HighChart.new('graph') do |f|
        f.title({ :text=>"MVP"})
        f.options[:xAxis][:categories] = @scores.map{|s| s[:date]}
        f.options[:chart][:zoomType] = 'x,y'
        f.series(:type=> 'column',:name=> @user.name,:data=> @scores.map{|s| s[:rate]}, maxPointWidth: 100)
        f.yAxis [ {:title => {:margin => 10}, :min => 0} ]
      end
    end
  end
end