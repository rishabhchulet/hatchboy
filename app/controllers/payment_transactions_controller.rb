class PaymentTransactionsController < ApplicationController

  before_filter :authenticate_account!

  def create
    payment = account_company.payments.where(id: params[:payment_id], status: Payment::STATUS_PREPARED).first or not_found

    payer = Payments::Factory.get(params[:payment_system], payment)
    payer.pay

    payment.update_attributes(status: Payment::STATUS_SENT, transaction_attributes: {
      payment_system: params[:payment_system], status: payer.status, info: payer.response.to_json
    })

    if payer.status_success?
      flash[:notice] = "You have succesfully sent a payment"
    else
      flash[:alert] = "Payment was not successfull"
    end

    redirect_to payments_path+"#sent"
  end


  def paypal_ipn
    my_logger ||= Logger.new("#{Rails.root}/log/paypal_ipn.log")
    my_logger.info(Time.now)
    my_logger.info(params.to_s)
    render text: ''
  end

end