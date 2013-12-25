class Team < ActiveRecord::Base
  
  belongs_to :company
  belongs_to :created_by, class_name: "Customer"
  
end
