module Hatchboy
  module Notifications
    class TeamsUserCreated < Factory
      attr_reader :team

      def initialize action, activity
        super activity
        @team = @object.team

        _unsubscribed_team = Arel::Table.new :unsubscribed_teams
        _subscriptions     = Arel::Table.new :subscriptions
        @recipients = @team.users.includes(:unsubscribed_teams, :subscriptions).references(:unsubscribed_teams, :subscriptions)
          .where(_unsubscribed_team[:team_id].eq(nil))
          .where(_subscriptions[:teams_users_created].eq(true))

        @email_name = :teames_users_created
      end

    end
  end
end
