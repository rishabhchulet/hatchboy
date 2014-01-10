require "spec_helper"

feature "teams#show" do
  
  background do
    @customer = create :customer
    @team = create :team, company: @customer.company
    @session = sign_in! @customer.account
    @session.visit team_path(@team)
  end
  
  scenario "it should contain team name and description" do
    @session.should have_content @team.name
    @session.should have_content @team.description
  end
  
  scenario "it should contain link to edit team page" do
    @session.find("a.edit-team").click
    @session.current_path.should eq edit_team_path @team
  end
  
  scenario "it should contain link to add time log" do
    @session.click_link "Add time log"
    @session.current_path.should eq new_work_log_path
  end

  scenario "it should contain link to add source" do
    @session.click_link "Add another source"
    @session.current_path.should eq new_source_path
  end

  context "when team has time logs" do
    
    before do
      @timelogs = create_list :work_log, 10, team: @team
      @session.visit team_path(@team)
    end
    
    it "should display list of teams' time logs" do
      data_rows = @session.all("#worklogs-list .data-row")
      data_rows.count.should eq 10
    end
    
    it "should have display information about worklog" do
      source_row = @session.all("#worklogs-list .data-row").first
      source_row.should have_content @timelogs.first.issue
      source_row.should have_content @timelogs.first.comment
    end
    
  end
  
  context "when team have sources" do
    
    before do
      @source = create :authorized_jira_source
      create :teams_sources, team: @team, source: @source
      @session.visit team_path(@team)
    end
    
    it "should display list of team's sources" do
      data_rows = @session.all("#sources-list .data-row")
      data_rows.count.should eq 1
    end
    
    it "should display information about sources" do
      source_row = @session.all("#sources-list .data-row").first
      source_row.should have_content @source.name
      source_row.should have_content @source.url
    end
  
  end
  
end
