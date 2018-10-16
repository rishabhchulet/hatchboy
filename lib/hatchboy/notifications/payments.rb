module Hatchboy
  module Notifications
    class Payments < Factory

      def initialize action, activity
        super activity
        @subscription_name = case action
          when 'update' then :payment_was_sent
        end
      end

      def recipients
        users = [@company.created_by] + [@owner] + @object.recipient_users
        get_subscribed users
      end

    end
  end
end
