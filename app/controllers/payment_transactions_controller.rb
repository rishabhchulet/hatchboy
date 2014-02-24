class PaymentTransactionsController < ApplicationController

  before_filter :authenticate_account!

  def create
    payment = account_company.payments.where(id: params[:payment_id], status: Payment::STATUS_PREPARED).first or not_found

    payer = Hatchboy::Payments::Factory.get(params[:payment_system])
    transaction = payer.mass_pay payment

    payment.update_attributes(status: Payment::STATUS_SENT, transaction_attributes: {
      payment_system: params[:payment_system], status: payer.status, info: transaction.to_json
    })

    if payer.status_success?
      flash[:notice] = "You have succesfully sent a payment"
    else
      flash[:alert] = "Payment was not successfull"
    end

    redirect_to payments_path(:anchor => 'sent')
  end

  def paypal_ipn
    my_logger ||= Logger.new("#{Rails.root}/log/paypal_ipn.log")
    my_logger.info(params.to_s)
    render text: ''
  end
  #//http://hatchboy2.shakuro.com/payment_transactions/paypal_ipn

end