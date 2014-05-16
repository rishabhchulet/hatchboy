module Hatchboy
  module Notifications
    class TeamsUsers < Factory

      def initialize action, activity
        super activity
        @subscription_name = case action
          when 'create' then :user_added_to_team
        end
      end

      def recipients
        team = @object.team
        subscribed_admins_recipients(team) + subscribed_users_recipients(team)
      end

    end
  end
end
