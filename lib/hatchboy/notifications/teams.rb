module Hatchboy
  module Notifications
    class Teams < Factory

      def initialize action, activity
        super activity
        @subscription_name = case action
          when 'create' then :team_was_added
          when 'destroy' then :team_was_removed
        end
      end

      def recipients
        if @subscription_name == :team_was_added
          admin_recipients
        elsif @subscription_name == :team_was_removed
          subscribed_admins_recipients @object
        end
      end

    end
  end
end
