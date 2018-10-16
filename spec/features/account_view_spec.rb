require "spec_helper"

feature "account#show" do

  background do
    @user = create :user
    @session = sign_in! @user.account
    @session.visit account_path
  end

  scenario "it should contain company name" do
    @session.should have_content @user.company.name
  end

  scenario "it should contain customers' email" do
    @session.should have_content @user.account.email
  end

  scenario "it should contain customers' name" do
    @session.should have_content @user.name
  end

  scenario "it should have link to edit account page" do
    @session.find("a.edit-account").click
    @session.current_path.should eq edit_account_registration_path
  end

end
