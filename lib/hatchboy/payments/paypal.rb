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
      end

      def pay payment
        recipients = payment.recipients.map { |recipient| [recipient.amount, recipient.user.account.email] }
        result = api.transfer(*recipients, {:subject => payment.description})

        additional_info = result.params.select { |key| %w(timestamp ack correlation_id version build).include? key }
        additional_info.merge!('test' => result.test?)

        if result.success?
          {success: true, additional_info: additional_info}
        else
          {success: false, message: "Paypal server error: #{result.message}. Error code: #{result.params['Errors']['error_code']}. Correlation id: #{result.params['correlation_id']}"}
        end
      end

      def valid?
        api.balance.success?
      end  

    end
  end
end
