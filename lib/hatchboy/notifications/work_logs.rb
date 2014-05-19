module Hatchboy
  module Notifications
    class WorkLogs < Factory

      def initialize action, activity
        super activity
        @subscription_name = case action
          when 'create' then :time_log_added_to_team
        end
      end

      def recipients
        team = @object.team
        subscribed_admins_recipients(team) + [@object.user]
      end

    end
  end
end
