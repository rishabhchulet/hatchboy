module Hatchboy
  module Notifications
    class Sources < Factory

      def initialize action, activity
        super activity
        @subscription_name = case action
          when 'create' then :data_source_was_created
        end
      end

      def recipients
        admin_recipients
      end

    end
  end
end
