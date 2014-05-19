class ReportPaymentsController < ApplicationController
  
  before_filter :check_session!

  include ReportsHelper

  def user
    @user = account_company.users.where(id: params[:user_id]).first or not_found
    query_params = retrieve_query_params :payments, [:date, :specific_date, :period_from, :period_to]
    user_payments = Hatchboy::Reports::Filters::PaymentsFilter.new(PaymentRecipient.where(user_id: @user.id).select(:payment_id).group(:payment_id)).with_statuses([Payment::STATUS_SENT, Payment::STATUS_MARKED]).filter_by_params(query_params).to_a
    
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