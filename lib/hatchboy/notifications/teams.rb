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
        @company.admins.with_account.joins(:subscription)
          .where(subscriptions: {@subscription_name => true}) if @company
      end

    end
  end
end
