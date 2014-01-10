require "spec_helper"

feature "work_log#destroy" do
  
  background do
    @customer = create :customer
    @session = sign_in! @customer.account
    @team = create :team, company: @customer.company
    
    @work_log = create :work_log, team: @team, employee: create(:employee, company: @customer.company)
    @session.visit team_path(@team)
    data_row = @session.all("#worklogs-list .data-row").first
    data_row.hover
    data_row.find(".list-row-action-delete-one").click
    popup_menu = @session.find(".list-row-action-popover-delete-one")
    popup_menu.find(:xpath, ".//input[@value = 'Delete']").click
  end
    
  scenario "should remove work log" do
    WorkLog.exists?(@work_log).should eq false
  end
  
  scenario "it should redirect to team page" do
    @session.current_path.should eq team_path(@team)
  end
  
end
