module Hatchboy
  module Payments
    class Paypal

      attr_reader :api, :last_response

      def initialize
        @api = PayPal::SDK::Merchant::API.new({
          # username: payment.company.paypal_api_username, 
          # password: payment.company.paypal_api_password,
          # signature: payment.company.paypal_api_signature,
          username: 'aglushkov_api1.shakuro.com',
          password: '1375773901',
          signature: 'A--8MSCLabuvN8L.-MHjxC9uypBtAFetCoCcp3ntAL0aS.jqhwGje6Gp'
          # username: 'anvamp_87_api1.mail.ru',
          # password: 'M9FT39FFTARD3BYX',
          # signature: 'A9N2POzRzQPqMVrcu-YbBtMtl8bOAUlMbh9HYUbWkEMhFCbipA-a7twa'          
        })
      end

      def mass_pay payment
        @last_response = api.mass_pay({
          :ReceiverType => "EmailAddress",
          :EmailSubject => payment.description,
          :NotifyURL => "http://hatchboy2.shakuro.com/payment_transactions/paypal_ipn",
          :MassPayItem => payment.recipients.map do |recipient| {
            :ReceiverEmail => recipient.user.account.email, 
            :UniqueId => recipient.id,
            :Amount => { 
              :currencyID => "USD", 
              :value => recipient.amount.to_s 
            }
          } end
        })
      end

      def transaction_search payment
        @last_response = api.transaction_search({
          :StartDate => payment.transaction.created_at,
          # :TransactionClass => 'MassPay',
          :Amount => payment.amount,
          :CurrencyCode => 'USD'
        })
      end

      def get_transaction_details transaction_id
        @last_response = api.get_transaction_details({:TransactionID => transaction_id}) 
      end

      def status
        if @last_response
          @last_response.response_status
        else
          payment.transaction.status if payment
        end
      end

      def status_success?
        status == "Success"
      end

    end
  end
end
