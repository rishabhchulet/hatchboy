require "spec_helper"

feature "company#show" do

  background do
    @user = create :user
    @session = sign_in! @user.account
  end

  scenario "it should contain company name" do
    @session.visit company_path
    @session.should have_content @user.company.name
  end

  scenario "it should contain company description" do
    @session.visit company_path
    @session.should have_content @user.company.description
  end

  scenario "it should contain contact person name" do
    @session.visit company_path
    @session.should have_content @user.name
  end

  scenario "it should contain information about user" do
    members = create_list :user, 2, company: @user.company
    members.map { |m| m.account.update_attribute(:created_at, 7.minutes.ago) }
    not_confirmed_account = create :not_confirmed_account, created_at: 5.minutes.ago, user: build(:user, company: @user.company)
    @user.account.update_attribute(:created_at, 20.minutes.ago)
    @session.visit company_path
    data_rows = @session.all("#users-short-list .data-row")
    data_rows.count.should eq 4
    data_rows.first.should have_content @user.status
    data_rows.first.should have_content @user.role
    data_rows.first.should have_content @user.name
    data_rows.first.should have_content @user.contact_email
#    data_rows.last.should have_content "not confirmed"
    data_rows.last.should have_content not_confirmed_account.user.name
#    data_rows.last.should have_content not_confirmed_account.user.contact_email
  end

  scenario "contact person should be clickable" do
    @session.visit company_path
    @session.find("#contact-person-link").click
    @session.current_path.should eq user_path(@user)
  end

  scenario "Invite another user link should be clickable" do
    @session.visit company_path
    @session.click_link "Invite user"
    @session.current_path.should eq new_user_invitation_path
  end

  scenario "it should have link to edit company page" do
    @session.find("a.edit-company").click
    @session.current_path.should eq edit_company_path
  end

  context "when company has users" do

    background do
      @user.update_attribute(:created_at, 20.minutes.ago)
      @users = create_list :user, 4, company: @user.company
      @users.first.update_attribute(:created_at, 10.minutes.ago)
      @users.second.update_attribute(:created_at, 7.minutes.ago)
      @users.third.update_attribute(:created_at, 4.minutes.ago)
      @users.fourth.update_attribute(:created_at, 2.minutes.ago)
      @session.visit company_path
    end

    let(:page) { @session }

    let(:collection) { [@user] + @users }

    it_should_behave_like "users list"

    scenario "should have link to create user page" do
      screenshot @session
      page.click_link "Add user"
      page.current_path.should eq new_user_path
    end

    scenario "should have link to delete user" do
      data_row = page.all("#users-short-list .data-row")[1]
      data_row.hover
      data_row.find(".list-row-action-delete-one").click
      popup_menu = page.find(".list-row-action-popover-delete-one")
      popup_menu.should be_visible
      popup_menu.all("div", :text => "Cancel").first.should be_visible
      popup_menu.find(:xpath, ".//input[@value = 'Delete']").click
      User.exists?(collection.second).should eq false
      page.current_path.should eq company_path
    end

  end

  context "when company has teams" do

    background do
      @teams = create_list :team, 4, company: @user.company
      @teams.first.update_attribute(:created_at, 10.minutes.ago)
      @teams.second.update_attribute(:created_at, 7.minutes.ago)
      @teams.third.update_attribute(:created_at, 4.minutes.ago)
      @teams.fourth.update_attribute(:created_at, 2.minutes.ago)
      @session.visit company_path
    end

    let(:page) { @session }

    let(:collection) { @teams }

    it_should_behave_like "teams list"

  end

end
