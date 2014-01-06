class Team < ActiveRecord::Base
  
  belongs_to :company
  belongs_to :created_by, class_name: "Customer"
  has_many :worklogs, :class_name => "WorkLog"
  
end
