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
        users = @company.admins + [@object.user]
        get_subscribed users, @object.team
      end

    end
  end
end
