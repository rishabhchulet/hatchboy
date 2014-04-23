class ReportPaymentsController < ApplicationController
  
  before_filter :check_session!

  include ReportsHelper

  def index
    @query_params = retrieve_query_params :payments, [:date, :users, :specific_date, :period_from, :period_to]
    payments = Hatchboy::ReportsFilters::PaymentsFilter.new.with_sended_payments.filter_by_params(@query_params).includes(:user).to_a
    @users_payments = payments.group_by(&:user_id)
    @users = payments.map(&:user).uniq.sort_by{|u| -@users_payments[u.id].map(&:amount).reduce(:+)}

    if payments.count > 0
      chart_data = group_timeline_from_params payments, @query_params do |scope, date|
        @users.collect do |user|
          payment = scope.select{|p| user.id == p.user_id}.first if scope
          { id: user.id, name: user.name, value: payment ? payment.amount.round(2) : 0}
        end
      end
      
      @chart = build_chart({title: "Payments", y_title: "$", data: chart_data})
    end
  rescue Exception => e
    flash.now[:error] = e.message
    render :index
  end

  def user
    @user = User.where(id: params[:user_id]).first or not_found
    query_params = retrieve_query_params :payments, [:date, :specific_date, :period_from, :period_to]
    user_payments = Hatchboy::ReportsFilters::PaymentsFilter.new(PaymentRecipient.where(user_id: @user.id).select(:payment_id).group(:payment_id)).with_sended_payments.filter_by_params(query_params).to_a
    
    @payments = user_payments.map(&:payment).uniq
    @payments_amounts = user_payments.group_by(&:payment_id)

    chart_data = group_timeline_from_params user_payments, query_params do |scope, date|
      @payments.collect do |payment|
        payment_rec = scope.select{|p| payment.id == p.payment_id}.first if scope
        { id: payment.id, name: "Payment \##{payment.id} - #{payment.created_by.name}", value: payment_rec ? payment_rec.amount.round(2) : 0}
      end
    end
    
    @chart = build_chart({title: "Payments", y_title: "$", data: chart_data})
  end
end