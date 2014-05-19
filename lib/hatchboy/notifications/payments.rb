module Hatchboy
  module Notifications
    class Payments < Factory

      def initialize action, activity
        super activity
        @subscription_name = case action
          when 'sent' then :payment_was_sent
        end
      end

      def recipients
        users = [@company.created_by] + [@owner] + @object.recipient_users
        get_subscribers users
      end

    end
  end
end
