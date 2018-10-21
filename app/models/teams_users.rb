class TeamsUsers < ActiveRecord::Base

  include PublicActivity::Model
  tracked except: :update,
          owner: ->(controller, model) { controller && controller.current_user },
          company_id: ->(controller, teams_users) { teams_users.team.company.id },
          comments: ->(controller, teams_users) {
            { team_id: teams_users.team.id,
              team_name: teams_users.team.name,
              user_id: teams_users.user.id,
              user_name: teams_users.user.name
            }.to_json
          }

  belongs_to :team, foreign_key: "team_id"
  belongs_to :user, foreign_key: "user_id"
  validates_presence_of :team
  validates_presence_of :user
  validates_uniqueness_of :user_id, scope: [:team_id], message: "has already been added"
  validates_uniqueness_of :team_id, scope: [:user_id], message: "has already been added"
  validate :companies_equality

  private

  def companies_equality
    errors.add :user_id, "Company should match team's company" unless team.company == user.company
  end
end

