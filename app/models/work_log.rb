class WorkLog < ActiveRecord::Base
  
  belongs_to :team
  belongs_to :source
  belongs_to :user

  validates :team, :presence => true
  validates :user, :presence => true
  validates :time, :presence => true

  def self.grouped
    group(:team_id, :user_id).select(:team_id, :user_id, "sum(time) as time")
  end

  def time=(t)
    write_attribute :time, (t.is_a?(String) ? (t.to_hours || t) : t)
  end
end