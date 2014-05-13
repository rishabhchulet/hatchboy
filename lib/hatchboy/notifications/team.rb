module Hatchboy
  module Notifications
    class Team < Factory

      def initialize action, activity
        super activity #sets @activity, @company, @object, @owner
        @action = case action
          when 'create' then :team_created
          when 'delete' then :team_deleted
        end
      end

      def recipients
        @company.users.where role: ["CEO", "Manager"]
      end

    end
  end
end
