require 'spec_helper'

describe Team do

  it { should belong_to :company }
  it { should belong_to :created_by }
  it { should have_many(:worklogs).dependent(:destroy) }
  it { should validate_presence_of :name }
  it { should have_many(:team_sources).class_name(TeamsSources).dependent(:destroy) }
  it { should have_many(:sources) }
  it { should have_many :users }
  it { should have_many(:posts).through(:post_receivers) }
  it { should have_many(:post_receivers) }

  it "should remove all worklogs logged to team" do
    team = create :team
    worklogs = create_list :work_log, 10, team: team
    expect{team.destroy}.to change{WorkLog.count}.from(10).to(0)
  end

  it "should remove links to all associated sources" do
    team = create :team
    source = create :authorized_jira_source
    team.sources << source
    expect{team.destroy}.to change{source.reload.source_teams.count}.from(1).to(0)
  end

  it "should join employee to project" do
    team = create :team
    user = create :user, company: team.company
    team.users << user
    user.reload.teams.should include team
  end

  it "should not contain duplicate entries" do
    team = create :team
    user = create :user, company: team.company
    team.users << user
    expect {team.users << user}.to raise_error
    team.reload.users.count.should eq 1
  end

  it "should validate companies equality" do
    team = create :team
    user = create :user
    expect {team.users << user}.to raise_error
  end

end

