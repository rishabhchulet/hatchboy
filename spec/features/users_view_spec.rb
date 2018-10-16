require "spec_helper"

feature "UsersController#show" do

  background do
    @user = create :user
    @session = sign_in! @user.account
    @user = create :user, company: @user.company
  end

  scenario "should display information about user" do
    @session.visit user_path @user
    @session.should have_content @user.name
    @session.should have_content @user.contact_email
    @session.should have_content @user.role
    @session.should have_content @user.status
  end

  scenario "should have link to edit user page" do
    @session.visit user_path @user
    @session.find("a.edit-user").click
    @session.current_path.should eq edit_user_path @user
  end

end

