class DashboardActivityFilter < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user

  ACTIVITIES = [:users, :post_receivers, :payments, :docu_signs, :sources, :teams, :work_logs]
end
