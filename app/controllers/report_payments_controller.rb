class ReportPaymentsController < ApplicationController
  
  before_filter :check_session!

  include ReportsHelper

  def index
    params[:date] ||= "all_time"
    payments = Hatchboy::ReportsFilters::PaymentsFilter.new.with_sended_payments.with_summ_amount
    payments = payments.filter_by_params(params)
    payments = payments.with_group_by_users
    @users = payments.to_a

    chart_data = group_scope_from_params payments, params do |scope, date|
      @users.map(&:user).uniq.collect do |user|
        payment = scope.select{|p| user.id == p.user_id}.first if scope
        { time: payment ? payment.amount.round(2) : 0, user: user }
      end
    end
    
    @chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.title({ :text=>"Payments"})
      f.options[:xAxis][:categories] = chart_data.keys
      f.options[:chart][:zoomType] = 'x,y'
      chart_data.values.flatten.group_by{|u| u[:user].id}.each do |id, user|
        f.series(:type=> 'column',:name=> user.first[:user].name,:data=> user.map{|d| d[:time]})
      end
      f.series(:type=> 'spline',:name=> 'Average', :data=> chart_data.values.collect{|w| w.map{|e| e[:time]}.instance_eval { (reduce(:+) / size.to_f).round(2) } })
      f.yAxis [
        {:title => {:text => "$", :margin => 10}, :min => 0},
      ]
      f.legend(:align => 'right', :verticalAlign => 'top', :y => 75, :x => -50, :layout => 'vertical')
    end
  rescue Exception => e
    flash.now[:error] = e.message
    render :index
  end

  def user
    @user = User.where(id: params[:user_id]).first or not_found
    @payments = Payment.includes(:created_by).joins(:recipients).where("payment_recipients.user_id = ?", @user.id).order("pr_created_at DESC").select("payments.*, amount AS user_amount").page params[:page]
  end
end