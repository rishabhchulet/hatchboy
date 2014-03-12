module Hatchboy
  module Payments
    class Paypal

      attr_reader :api, :last_response

      def initialize params
        @api = ActiveMerchant::Billing::PaypalGateway.new(
          login: params[:login],
          password: params[:password],
          signature: params[:signature]
        )
          # login: 'aglushkov_api1.shakuro.com',
          # password: '1375773901',
          # signature: 'A--8MSCLabuvN8L.-MHjxC9uypBtAFetCoCcp3ntAL0aS.jqhwGje6Gp'
      end

      def pay payment
        recipients = payment.recipients.map { |recipient| [recipient.amount, recipient.user.account.email] }
        result = api.transfer(*recipients, [1, 'aglushkovshakuro.com'], {:subject => payment.description})

        if result.message == "Success"
          { success: true }
        else
          { success: false, message: "Paypal server error: #{result.message}. Error code: #{result.Errors['error_code']}. Correlation id: #{result.correlation_id}" }
        end
      end

      def valid?
        api.balance.success?
      end  

    end
  end
end
