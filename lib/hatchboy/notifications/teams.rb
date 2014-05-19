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
          get_subscribers @company.admins
        elsif @subscription_name == :team_was_removed
          get_subscribers @company.admins, @object
        end
      end

    end
  end
end
