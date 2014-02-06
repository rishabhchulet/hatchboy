require "spec_helper"

feature "work_log#destroy" do

  background do
    @user = create :user
    @session = sign_in! @user.account
    @team = create :team, company: @user.company

    @work_log = create :work_log, team: @team, user: create(:user, company: @user.company)
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
