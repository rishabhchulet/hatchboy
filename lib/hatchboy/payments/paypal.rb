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

      def self.get_sum type, receivers, status=nil
        amount = 0.0
        receivers.each do |r|
          amount += r[type] if status.nil? or status==r[status]
        end
        amount
      end  

      def self.parse_ipn ipn_params
        receivers = parse_ipn_receivers(ipn_params)

        amount = get_sum :amount, receivers
        fee = get_sum :fee, receivers
        total = amount + fee

        completed_amount = get_payment_amount(ipn_params)

        transaction = {
          transaction: {
            type: (ipn_params['txn_type']=='masspay' ? "Mass Payment" : ipn_params['txn_type']),
            ipn_track_id: ipn_params['ipn_track_id'],
            test_ipn: ipn_params['test_ipn']
          },
          payment: {
            payment_date: ipn_params['payment_date'],
            payment_status: ipn_params['payment_status'],
            payment_amount: amount,
            fee_amount: fee,
            total_amount: total,
            completed_amount: get_sum(:amount, receivers, 'Completed'),
            unclaimed_amount: get_sum(:amount, receivers, 'Unclaimed'),
            returned_amount: get_sum(:amount, receivers, 'Returned'),
            denied_amount: get_sum(:amount, receivers, 'Denied'),
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
            continue if keys.include? receiver_number

            receivers << ({ 
              status: ipn_params["status_#{receiver_number}"],
              error_code: ipn_params["reason_code_#{receiver_number}"],
              email: ipn_params["receiver_email_#{receiver_number}"],
              amount: mc_gross_["payment_gross_#{receiver_number}"],
              currency: ipn_params["mc_currency_#{receiver_number}"],
              fee: ipn_params["mc_fee_#{receiver_number}"],
              transaction_id: ipn_params["masspay_txn_id_#{receiver_number}"]
            })

            keys << receiver_number
          end
        end
        receivers
      end


      def self.payer_status_message status
      end

      def self.reason_code_message status
      end  

      def self.payment_status_message status
        case status
        when 'Canceled_Reversal' then 'A reversal has been canceled. For example, you won a dispute with the customer, and the funds for the transaction that was reversed have been returned to you.'
        when 'Completed' then 'The payment has been completed, and the funds have been added successfully to your account balance.'
        when 'Created' then 'A German ELV payment is made using Express Checkout.'
        when 'Denied' then 'The payment was denied. This happens only if the payment was previously pending because of one of the reasons listed for the pending_reason variable or the Fraud_Management_Filters_x variable.'
        when 'Expired' then 'This authorization has expired and cannot be captured.'
        when 'Failed' then 'The payment has failed. This happens only if the payment was made from your customer\'s bank account.'
        when 'Pending' then 'The payment is pending. See pending_reason for more information.'
        when 'Refunded' then 'You refunded the payment.'
        when 'Reversed' then 'A payment was reversed due to a chargeback or other type of reversal. The funds have been removed from your account balance and returned to the buyer. The reason for the reversal is specified in the ReasonCode element.'
        when 'Processed' then 'A payment has been accepted.'
        when 'Voided' then 'This authorization has been voided.'
        end
      end


      def self.transaction_status_message status
        case status
        when 'Completed' then "All of your payments have been claimed, or after a period of 30 days, unclaimed payments have been returned to you."
        when 'Denied' then 'Your funds were not sent and the Mass Payment was not initiated. This may have been caused by lack of funds.'
        when 'Processed' then "Your Mass Payment has been processed and all payments have been sent."
        end
      end

      def self.receiver_payment_status_message status
        case status
        when 'Completed' then "The payment has been processed, regardless of whether this was originally a unilateral payment"
        when 'Failed' then "The payment failed because of an insufficient PayPal balance."
        when 'Returned' then "When an unclaimed payment remains unclaimed for more than 30 days, it is returned to the sender."
        when 'Reversed' then "PayPal has reversed the transaction."
        when 'Unclaimed' then "This is for unilateral payments that are unclaimed."
        when 'Pending' then "The payment is pending because it is being reviewed for compliance with government regulations. The review will be completed and the payment status will be updated within 72 hours."
        when 'Blocked' then "This payment was blocked due to a violation of government regulations."
        end
      end

      def self.receiver_error_message code
        case code.to_i
          when 1001 then "Receiver's account is invalid"
          when 1002 then "Sender has insufficient funds"
          when 1003 then "User's country is not allowed"
          when 1004 then "User's credit card is not in the list of allowed countries of the gaming merchant"
          when 3004 then "Cannot pay self"
          when 3014 then "Sender's account is locked or inactive"
          when 3015 then "Receiver's account is locked or inactive "
          when 3016 then "Either the sender or receiver exceeded the transaction limit"
          when 3017 then "Spending limit exceeded"
          when 3047 then "User is restricted"
          when 3078 then "Negative balance"
          when 3148 then "Receiver's address is in a non-receivable country or a PayPal zero country"
          when 3535 then "Invalid currency"
          when 3547 then "Sender's address is located in a restricted State "
          when 3558 then "Receiver's address is located in a restricted State "
          when 3769 then "Market closed and transaction is between 2 different countries"
          when 4001 then "Internal error"
          when 4002 then "Internal error"
          when 8319 then "Zero amount"
          when 8330 then "Receiving limit exceeded"
          when 9302 then "Transaction was declined "
          when 11711 then "Per-transaction sending limit exceeded"
          when 14159 then "Transaction currency cannot be received by the recipient"
          when 14550 then "Currency compliance"
          when 14764 then "Regulatory review - Pending"
          when 14765 then "Regulatory review - Blocked"
          when 14767 then "Receiver is unregistered"
          when 14768 then "Receiver is unconfirmed"
          when 14769 then "Youth account recipient"
          when 14800 then "POS cumulative sending limit exceeded"
        end
      end

    end
  end
end
