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
        recipients = payment.recipients.map { |recipient| [recipient.amount*100, recipient.user.account.email, {unique_id: recipient.id, note: payment.description}] }
        result = api.transfer *recipients, subject: payment.description

        additional_info = result.params.select { |key| %w(timestamp ack correlation_id version build).include? key }
        additional_info.merge! 'test' => result.test?

        if result.success?
          {success: true, additional_info: additional_info}
        else
          {success: false, message: "Paypal server error: #{result.message}. Error code: #{result.params['Errors']['error_code']}. Correlation id: #{result.params['correlation_id']}"}
        end
      end

      def valid?
        api.balance.success?
      end

      def self.get_sum type, receivers, status=[]
        amount = 0.0
        status = Array.wrap(status)
        receivers.each do |r|
          amount += r[type] if status.empty? or status.include?(r[:status])
        end
        amount
      end  

      def self.parse_ipn ipn_params
        receivers = parse_ipn_receivers(ipn_params)

        amount = get_sum :amount, receivers
        fee = get_sum :fee, receivers
        total = amount + fee

        transaction = {
          transaction: {
            type: (ipn_params['txn_type']=='masspay' ? "Mass Payment" : ipn_params['txn_type']),
            ipn_track_id: ipn_params['ipn_track_id'],
            test_ipn: (ipn_params['test_ipn'] ? true : false)
          },
          payment: {
            payment_date: ipn_params['payment_date'],
            payment_status: ipn_params['payment_status'],
            payment_amount: amount,
            fee_amount: fee,
            total_amount: total,
            completed_amount: get_sum(:amount, receivers, 'Completed'),
            unclaimed_amount: get_sum(:amount, receivers, 'Unclaimed'),
            returned_amount: get_sum(:amount, receivers, ['Returned', 'Reverced']),
            denied_amount: get_sum(:amount, receivers, 'Failed'),
            pending_amount: get_sum(:amount, receivers, 'Pending'),
            blocked_amount: get_sum(:amount, receivers, 'Blocked')
          },
          payer: {
            name: "#{ipn_params['first_name']} #{ipn_params['last_name']}",
            business_name: ipn_params['payer_business_name'],
            email: ipn_params['payer_email'],
            country: ipn_params['residence_country'],
            status: ipn_params['payer_status'],
            payer_id: ipn_params['payer_id']
          },
          receivers: parse_ipn_receivers(ipn_params)
        }
      end

      def self.parse_ipn_receivers ipn_params
        keys = []
        receivers = []
        ipn_params.each do |key, value|
          if match = key.match(/_(\d+)$/)
            receiver_number = match[1];
            next if keys.include? receiver_number

            receivers << ({ 
              status: ipn_params["status_#{receiver_number}"],
              error_code: ipn_params["reason_code_#{receiver_number}"].to_s,
              email: ipn_params["receiver_email_#{receiver_number}"],
              amount: ipn_params["mc_gross_#{receiver_number}"].to_f,
              currency: ipn_params["mc_currency_#{receiver_number}"],
              fee: ipn_params["mc_fee_#{receiver_number}"].to_f,
              transaction_id: ipn_params["masspay_txn_id_#{receiver_number}"]
            })

            keys << receiver_number
          end
        end
        receivers
      end
    end
  end
end
