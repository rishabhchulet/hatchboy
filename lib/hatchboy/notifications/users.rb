module Hatchboy
  module Notifications
    class Users < Factory

      def initialize action, activity
        super activity
        @action = case action
          when 'create' then :user_created
          when 'destroy' then :user_deleted
        end
      end

      def recipients
        @company.users.where role: ["CEO", "Manager"] if @company
      end

    end
  end
end
