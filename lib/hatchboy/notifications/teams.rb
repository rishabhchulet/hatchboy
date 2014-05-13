module Hatchboy
  module Notifications
    class Teams < Factory

      def initialize action, activity
        super activity
        @action = case action
          when 'create' then :team_created
          when 'destroy' then :team_deleted
        end
      end

      def recipients
        @company.users.where role: ["CEO", "Manager"]
      end

    end
  end
end
