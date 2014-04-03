class ReportsPaymentsController < ApplicationController
  
  before_filter :check_session!

  include ReportsHelper

  def index
    params[:date] ||= "all_time"
    payments = Hatchboy::ReportsFilters::PaymentsFilter.new.with_summ_amount
    payments = payments.filter_by_params(params)

    @users = payments.with_group_by_users.includes(:user).to_a

    chart_data = prepare_chart_data_scope payments, params do |data_scope, date|
      workflow = (date.is_a? Integer) ? data_scope.select{|w| w.created_at.to_time.hour == date}.first : data_scope.select{|w| w.created_at.to_time == date}.first
      if workflow
        workflow.amount
      end
    end
    @chart = build_chart_object("Financial", "Amount", chart_data)
    
  rescue Exception => e
    flash.now[:error] = e.message
    render :index
  end

  def user
    @user = User.where(id: params[:user_id]).first or not_found
    @payments = Payment.includes(:created_by).joins(:recipients).where("payment_recipients.user_id = ?", @user.id).order("created_at DESC").select("payments.*, amount AS user_amount").page params[:page]
  end
end