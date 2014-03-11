shared_examples "teams list" do
  
  scenario "it should contain information abount teams" do
    data_rows = page.all("#teams-short-list .data-row")
    data_rows.count.should eq 4
    data_rows.first.should have_content collection.first.id
    data_rows.first.should have_content collection.first.name
    data_rows.first.should have_content collection.first.description
  end
  
  scenario "should have link to create another team" do
    page.click_link "Create new team" 
    page.current_path.should eq new_team_path
  end
  
  scenario "should have link to view team" do
    data_row = page.all("#teams-short-list .data-row")[1]
    data_row.hover
    data_row.find(".view-team-action").click
    page.current_path.should eq team_path(collection.second)
  end
  
  scenario "should have link to edit team data" do
    data_row = page.all("#teams-short-list .data-row")[1]
    data_row.hover
    data_row.find(".edit-team-action").click
    page.current_path.should eq edit_team_path(collection.second)
  end

  scenario "should have link to delete team" do
    data_row = page.all("#teams-short-list .data-row")[1]
    data_row.hover
    data_row.find(".list-row-action-delete-one").click
    popup_menu = page.find(".list-row-action-popover-delete-one")
    popup_menu.should be_visible
    popup_menu.all("div", :text => "Cancel").first.should be_visible
    popup_menu.find(:xpath, ".//input[@value = 'Delete']").click
    Team.exists?(collection.second).should eq false
    page.current_path.should eq company_path
  end
  
  scenario "it should not include teams from other companies" do
    another_company_teams = create_list :team, 4, company: create(:company)
    page.visit page.current_url
    page.all("#teams-short-list .data-row").count.should eq 4
  end
end
