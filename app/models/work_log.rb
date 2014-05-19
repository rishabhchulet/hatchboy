class WorkLog < ActiveRecord::Base
  include PublicActivity::Model
  tracked only: :create,
          owner: ->(controller, model) { controller && controller.current_user },
          company_id: ->(controller, work_log) { work_log.team.company_id },
          comments: ->(controller, work_log) { {comment: work_log.comment}.to_json }

  belongs_to :team
  belongs_to :source
  belongs_to :user

  validates :team, :presence => true
  validates :user, :presence => true
  validates :time, :presence => true

  def self.grouped
    group(:team_id, :user_id).select(:team_id, :user_id, "sum(time) as time")
  end
end