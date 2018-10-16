require "spec_helper"

feature "teams#show" do

  background do
    @user = create :user, created_at: 20.minutes.ago
    @team = create :team, company: @user.company
    @session = sign_in! @user.account
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
    @session.current_path.should eq new_team_work_log_path @team
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

  context "when team has posts" do

    before do
      10.times{ |i| @team.posts.create( FactoryGirl.attributes_for(:post).merge(user: @user) ) }
      
      @session.visit team_path(@team)
    end

    it "should display list of posts" do
      data_rows = @session.all("#posts-list .data-row")
      data_rows.count.should eq 10
    end

    it "should have display information about post" do
      source_row = @session.all("#posts-list .data-row").first
      source_row.should have_content @team.posts.first.subject
      source_row.should have_content @team.posts.first.message
    end

  end

  context "when team has sources" do

    before do
      @source = create :authorized_jira_source
      create :teams_sources, team: @team, source: @source
      @session.visit team_path(@team)
    end

    let(:page) { @session }

    let(:collection) { [@source] }

    it_should_behave_like "sources list"
  end

  context "when team has users" do

    background do
      @users = create_list :user, 6, company: @team.company
      other_users = create_list :user, 3, company: @team.company
      @team.users << @users
      @session.visit team_path(@team)
    end

    let(:page) { @session }

    let(:collection) { @users }

    it_should_behave_like "users list"

    scenario "should have link to add user to team" do
      page.click_link "Add user"
      page.current_path.should eq new_team_user_path(@team)
    end

    scenario "should have link to delete user" do
      data_row = page.all("#users-short-list .data-row")[1]
      data_row.hover
      data_row.find(".list-row-action-delete-one").click
      popup_menu = page.find(".list-row-action-popover-delete-one")
      popup_menu.should be_visible
      popup_menu.find(:xpath, ".//input[@value = 'Delete']").click
      @team.reload.users.should_not include collection.second
      page.current_path.should eq team_path(@team)
    end

  end

end

