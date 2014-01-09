require 'spec_helper'

describe Team do
  
  it {should belong_to :company }
  it {should belong_to :created_by }
  it {should have_many :worklogs } 
  
  it "should remove all worklogs logged to team" do
    team = create :team
    worklogs = create_list :work_log, 10, team: team
    expect{team.destroy}.to change{WorkLog.count}.from(10).to(0)
  end
  
end
