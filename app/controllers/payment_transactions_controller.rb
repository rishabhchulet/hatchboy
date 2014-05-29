class PaymentTransactionsController < ApplicationController
  before_action :authenticate_account!, :except => [:paypal_notify, :stripe_notify] 
  skip_before_action :verify_authenticity_token, :only => [:paypal_notify, :stripe_notify]

  def create
    payment_configuration = case params[:type]
      when 'paypal' then account_company.paypal_configuration
      when 'dwolla' then account_company.dwolla_configuration
      when 'stripe' then account_company.stripe_configuration 
    end
    
    unless payment_configuration
      flash[:alert] = "You should configurate this service to use you paypal account before sending payments"
      redirect_to(new_paypal_configuration_path) and return
    end

    payment = account_company.payments.where(id: params[:payment_id], status: Payment::STATUS_PREPARED).first or not_found
    payer = Hatchboy::Payments::Factory.get(params[:type], payment_configuration)
    response = payer.pay payment

    if response[:success]
      payment.update_attributes(status: Payment::STATUS_SENT, additional_info: response[:additional_info].to_json, type: params[:type])

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
          transaction = Hatchboy::Payments::Paypal.parse_ipn params
          payment = first_recipient.payment
          payment.transactions.create(info: transaction.to_json)
        end
      else
        paypal_ipn_logger ||= Logger.new("#{Rails.root}/log/paypal_ipn.log")
        paypal_ipn_logger.warn('Can\'t verify paypal notification !')
      end
    end

    render :nothing => true
  end

  def stripe_notify
    stripe_logger ||= Logger.new("#{Rails.root}/log/stripe.log")

    if json_event = JSON.parse(request.raw_post)
      if json_event["data"]["object"]["object"] == "transfer"
        if recipient = PaymentRecipient.where(stripe_transfer_id: json_event["data"]["object"]["id"]).first
          stripe = Hatchboy::Payments::Stripe.new recipient.payment.company.stripe_configuration
          if event = stripe.get_event(json_event["id"])
            recipient.payment.transactions.create(info: event.to_json)
          else
            stripe_logger.warn("Can't find event #{json_event["id"]}!")
          end
        else
          stripe_logger.warn("Can't find recipient in transfer #{json_event["data"]["object"]["id"]}!")
        end
      end
    end

    render :nothing => true
  end

end
