module Hatchboy
  module Notifications
    class Users < Factory

      def initialize action, activity
        super activity
        @subscription_name = case action
          when 'create' then :user_was_added
          when 'destroy' then :user_was_removed
        end
      end

      def recipients
        get_subscribed @company.admins if @company
      end

    end
  end
end
