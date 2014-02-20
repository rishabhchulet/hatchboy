module Payments
  class Paypal < Factory

    attr_reader :payment, :response

    def initialize payment
      @payment = payment
    end

    def pay
      api = PayPal::SDK::Merchant::API.new({
        # username: payment.company.paypal_api_username, 
        # password: payment.company.paypal_api_password,
        # signature: payment.company.paypal_api_signature,
        username: 'aglushkov_api1.shakuro.com',
        password: '1375773901',
        signature: 'A--8MSCLabuvN8L.-MHjxC9uypBtAFetCoCcp3ntAL0aS.jqhwGje6Gp'
      })

      @response = api.mass_pay({
        :ReceiverType => "EmailAddress",
        :NotifyURL => "http://#{Hatchboy::Application.config.action_mailer.default_url_options[:host]}/payment_transactions/paypal_ipn",
        :MassPayItem => payment.recipients.map do |recipient| {
          :ReceiverEmail => recipient.user.account.email, 
          :Note => payment.description,
          :Amount => { 
            :currencyID => "USD", 
            :value => recipient.amount.to_s 
          }
        } end
      });
    end

    def status
      response.response_status
    end

    def status_success?
      status == "Success"
    end  

  end
end


