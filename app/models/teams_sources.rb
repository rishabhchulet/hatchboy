class TeamsSources < ActiveRecord::Base
  
  belongs_to :source
  
  belongs_to :team
  
end
