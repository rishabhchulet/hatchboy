class WorkLog < ActiveRecord::Base

  paginates_per 50
  
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