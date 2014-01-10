require "spec_helper"

feature "sources#view" do
  
  background do
    @customer = create :customer
    @session = sign_in! @customer.account
    @jira_source = create :authorized_jira_source, company: @customer.company
    @jira_source.teams << @team = create(:team)
    @worklogs = create_list :imported_work_log, 5, source: @jira_source, team: @team
    @session.visit jira_source_path @jira_source
  end
  
  scenario "it should contain jira source description" do
    @session.should have_content @jira_source.name
    @session.should have_content @jira_source.url
    @session.should have_content @jira_source.consumer_key
  end
  
  scenario "it contain imported time logs" do
    data_rows = @session.all("#worklogs-list .data-row")
    data_rows.count.should eq 5
    source_row = @session.all("#worklogs-list .data-row").first
    source_row.should have_content @worklogs.first.issue
    source_row.should have_content @worklogs.first.comment
    source_row.should have_content @worklogs.first.team.name
  end
  
  scenario "it should have edit source link" do
    @session.find("a.edit-jira-source").click
    @session.current_path.should eq edit_jira_source_path @jira_source
  end  

  scenario "it should have edit link for time logs" do
    source_row = @session.all("#worklogs-list .data-row").first
    source_row.hover
    source_row.find(".edit-worklog-action").click
    @session.current_path.should eq edit_team_work_log_path(@jira_source.worklogs.first.team, @jira_source.worklogs.first)
  end  

  scenario "should have delete link for time logs" do
    source_row = @session.all("#worklogs-list .data-row").first
    source_row.hover
    source_row.find(".list-row-action-delete-one").click
    popup_menu = @session.find(".list-row-action-popover-delete-one")
    popup_menu.should be_visible
    popup_menu.all("div", :text => "Cancel").first.should be_visible
    popup_menu.find(:xpath, ".//input[@value = 'Delete']").should be_visible
  end
  
  scenario "it should not show timelogs not related to the source" do
    more_worklogs = create_list :imported_work_log, 10, team: team = create(:team), source: source = create(:authorized_jira_source, company: team.company)
    @session.visit jira_source_path @jira_source
    @session.all("#worklogs-list .data-row").count.should eq 5
    @session.visit jira_source_path source
    @session.all("#worklogs-list .data-row").count.should eq 10
  end
  
end
