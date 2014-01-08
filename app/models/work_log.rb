class WorkLog < ActiveRecord::Base

  belongs_to :team
  belongs_to :source
  belongs_to :sources_user
  belongs_to :employee
  
end
