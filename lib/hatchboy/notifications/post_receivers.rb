module Hatchboy
  module Notifications
    class PostReceivers < Factory

      def initialize action, activity
        super activity
        if @object.receiver_type == 'Team'
          @subscription_name = case action
            when 'create' then :post_added_to_team
          end
        end
      end

      def recipients
        if @object.receiver_type == 'Team'
          team = @object.receiver
          subscribed_admins_recipients(team) + subscribed_users_recipients(team)
        end
      end

    end
  end
end
