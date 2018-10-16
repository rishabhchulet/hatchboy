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
          users = @company.admins + @object.receiver.users
          get_subscribed users, @object.receiver
        end
      end

    end
  end
end
