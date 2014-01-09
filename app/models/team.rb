class Team < ActiveRecord::Base
  
  belongs_to :company
  belongs_to :created_by, class_name: "Customer"
  
  has_many :teams_sources, :class_name => "TeamsSources"
  has_many :sources, :through => :teams_sources
  
  has_many :worklogs, :class_name => "WorkLog", :dependent => :destroy
  
end
