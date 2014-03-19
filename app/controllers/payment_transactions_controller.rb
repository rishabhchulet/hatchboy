class PaymentTransactionsController < ApplicationController
  before_action :authenticate_account!, :except => :paypal_notify 
  skip_before_action :verify_authenticity_token, :only => :paypal_notify

  def create
    payment_configuration = case params[:type]
      when 'paypal' then account_company.paypal_configuration
      when 'dwolla' then account_company.dwolla_configuration 
    end
    
    unless payment_configuration
      flash[:alert] = "You should configurate this service to use you paypal account before sending payments"
      redirect_to(new_paypal_configuration_path) and return
    end

    payment = account_company.payments.where(id: params[:payment_id], status: Payment::STATUS_PREPARED).first or not_found
    payer = Hatchboy::Payments::Factory.get(params[:type], payment_configuration)
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
    notify = ActiveMerchant::Billing::Integrations::Paypal::Notification.new(request.raw_post)

    if notify.params['txn_type'] == "masspay"
      if notify.acknowledge
        if notify.params['unique_id_1'] and first_recipient = PaymentRecipient.find(notify.params['unique_id_1'])
          
          paypal_ipn_logger ||= Logger.new("#{Rails.root}/log/paypal_ipn_test.log")  

          transaction = Hatchboy::Payments::Paypal.parse_ipn params

          paypal_ipn_logger.info("1")
          paypal_ipn_logger.info(transaction)

          payment = first_recipient.payment

          paypal_ipn_logger.info("2")
          paypal_ipn_logger.info(payment)

          payment.transactions.create(info: transaction.to_json)

          paypal_ipn_logger.info("3")
          paypal_ipn_logger.info(payment.transactions.last)          
        end
      else
        paypal_ipn_logger ||= Logger.new("#{Rails.root}/log/paypal_ipn.log")
        paypal_ipn_logger.warn('Can\'t verify paypal notification !')
      end
    end

    render :nothing => true
  end

end
