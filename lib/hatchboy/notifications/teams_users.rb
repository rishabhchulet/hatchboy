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
        users = @company.admins + @object.team.users
        get_subscribers users, @object.team
      end

    end
  end
end
