module Hatchboy
  module Notifications
    class TeamsUsers < Factory
      attr_reader :team

      def initialize action, activity
        super activity
        @team = @object.team

        _unsubscribed_team = Arel::Table.new :unsubscribed_teams
        _subscriptions = Arel::Table.new :subscriptions
        @recipients = @team.users.includes(:unsubscribed_teams, :subscriptions).references(:unsubscribed_teams, :subscriptions)
          .where(_unsubscribed_team[:team_id].eq(nil))
          .where(subscriptions[:teames_users_created].eq(true))
        @email_name = :teames_users_created
      end

    end
  end
end
  # t.integer  "company_id"
  # t.integer  "trackable_id"
  # t.string   "trackable_type"
  # t.integer  "owner_id"
  # t.string   "owner_type"
  # t.string   "key"
  # t.text     "parameters"
  # t.text     "comments"
  # t.integer  "recipient_id"
  # t.string   "recipient_type"
  # t.datetime "created_at"
  # t.datetime "updated_at"