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
        get_subscribers @company.admins
      end

    end
  end
end
