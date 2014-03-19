module PaymentsHelper

      def paypal_payer_status_message status
        case status
        when 'verified' then 'Customer has a verified PayPal account.'
        when 'unverified' then 'Customer has an unverified PayPal account.'
        end
      end
      def paypal_payment_status_message status
        case status
        when 'Completed' then 'All of your payments have been claimed, or after a period of 30 days, unclaimed payments have been returned to you.'
        when 'Denied' then 'Your funds were not sent and the Mass Payment was not initiated. This may have been caused by lack of funds.'
        when 'Processed' then 'Your Mass Payment has been processed and all payments have been sent.'
        end
      end

      def paypal_receiver_status_message status
        case status
        when 'Completed' then 'The payment has been processed, regardless of whether this was originally a unilateral payment'
        when 'Failed' then 'The payment failed because of an insufficient PayPal balance.'
        when 'Returned' then 'When an unclaimed payment remains unclaimed for more than 30 days, it is returned to the sender.'
        when 'Reversed' then 'PayPal has reversed the transaction.'
        when 'Unclaimed' then 'This is for unilateral payments that are unclaimed.'
        when 'Pending' then 'The payment is pending because it is being reviewed for compliance with government regulations. The review will be completed and the payment status will be updated within 72 hours.'
        when 'Blocked' then 'This payment was blocked due to a violation of government regulations.'
        end
      end

      def paypal_receiver_error_message code
        case code.to_i
        when 1001 then 'Receiver\'s account is invalid'
        when 1002 then 'Sender has insufficient funds'
        when 1003 then 'User\'s country is not allowed'
        when 1004 then 'User\'s credit card is not in the list of allowed countries of the gaming merchant'
        when 3004 then 'Cannot pay self'
        when 3014 then 'Sender\'s account is locked or inactive'
        when 3015 then 'Receiver\'s account is locked or inactive'
        when 3016 then 'Either the sender or receiver exceeded the transaction limit'
        when 3017 then 'Spending limit exceeded'
        when 3047 then 'User is restricted'
        when 3078 then 'Negative balance'
        when 3148 then 'Receiver\'s address is in a non-receivable country or a PayPal zero country'
        when 3535 then 'Invalid currency'
        when 3547 then 'Sender\'s address is located in a restricted State'
        when 3558 then 'Receiver\'s address is located in a restricted State'
        when 3769 then 'Market closed and transaction is between 2 different countries'
        when 4001 then 'Internal error'
        when 4002 then 'Internal error'
        when 8319 then 'Zero amount'
        when 8330 then 'Receiving limit exceeded'
        when 9302 then 'Transaction was declined'
        when 11711 then 'Per-transaction sending limit exceeded'
        when 14159 then 'Transaction currency cannot be received by the recipient'
        when 14550 then 'Currency compliance'
        when 14764 then 'Regulatory review - Pending'
        when 14765 then 'Regulatory review - Blocked'
        when 14767 then 'Receiver is unregistered'
        when 14768 then 'Receiver is unconfirmed'
        when 14769 then 'Youth account recipient'
        when 14800 then 'POS cumulative sending limit exceeded'
        end
      end

end

