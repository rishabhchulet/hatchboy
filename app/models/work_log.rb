class WorkLog < ActiveRecord::Base

  belongs_to :team
  belongs_to :source
  belongs_to :user

  validates :team, :presence => true
  validates :user, :presence => true
  validates :time, :presence => true

end

