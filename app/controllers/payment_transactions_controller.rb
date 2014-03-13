class PaymentTransactionsController < ApplicationController
  before_action :authenticate_account!, :except => :paypal_notify 
  skip_before_action :verify_authenticity_token, :only => :paypal_notify

  def create
    payment_configuration = case params[:payment_system]
      when 'paypal' then account_company.paypal_configuration
      when 'dwolla' then account_company.dwolla_configuration 
    end
    
    unless payment_configuration
      flash[:alert] = "You should configurate this service to use you paypal account before sending payments"
      redirect_to(new_paypal_configuration_path) and return
    end  

    payment = account_company.payments.where(id: params[:payment_id], status: Payment::STATUS_PREPARED).first or not_found
    payer = Hatchboy::Payments::Factory.get(params[:payment_system], payment_configuration)
    response = payer.pay payment

    if response[:success]
      payment.update_attributes(status: Payment::STATUS_SENT, additional_info: response[:additional_info].to_json)

      flash[:notice] = "You have succesfully sent a payment"
      redirect_to payments_path(:anchor => 'payments-sent')
    else
      flash[:alert] = response[:message]
      redirect_to payments_path
    end
  end

  def paypal_notify
    my_logger ||= Logger.new("#{Rails.root}/log/paypal_notify.log")
    my_logger.info(params.to_s)

    notify = ActiveMerchant::Billing::Integrations::Paypal::Notification.new(request.raw_post)
    PaymentTransaction.create(info: notify.to_json, payment_system: 'paypal', status: notify.status)

    # t.integer  "payment_id"
    # t.string   "payment_system"
    # t.string   "status"
    # t.text     "info"
    # t.datetime "created_at"
    # t.datetime "updated_at"

    # p "Notification object is #{notify}"
    # if notify.acknowledge
    #   p "Transaction ID is #{notify.transaction_id}"
    #   p "Notification object is #{notify}"
    #   p "Notification status is #{notify.status}"
    # end
    render :nothing => true
  end

end
