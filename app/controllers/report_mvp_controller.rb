class ReportMvpController < ApplicationController
  
  before_filter :check_session!

  include ReportsHelper

  def user
    @user = User.where(id: params[:user_id]).first or not_found
    params[:date] = "all_time"
    params[:users] = @user.id
    payments = Hatchboy::Reports::Filters::PaymentsFilter.new.with_sended_payments.filter_by_params(params).to_a
    worklogs = Hatchboy::Reports::Filters::WorkLogsFilter.new.filter_by_params(params).to_a
    
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