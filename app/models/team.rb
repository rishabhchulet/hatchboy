class Team < ActiveRecord::Base
  
  belongs_to :company
  belongs_to :created_by, class_name: "Customer"
  
  has_many :team_sources, :class_name => "TeamsSources", :dependent => :destroy
  has_many :sources, :through => :team_sources
  
  has_many :worklogs, :class_name => "WorkLog", :dependent => :destroy
  
  validates :name, :presence => true
  
end
