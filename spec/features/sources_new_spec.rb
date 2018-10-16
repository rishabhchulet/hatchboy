require "spec_helper"

feature "sources#new" do

  background do
    @user = create :user
    @session = sign_in! @user.account
    @session.visit new_source_path
  end

  scenario "it have tab to create JIRA source" do
    @session.click_link("JIRA Source")
    @session.should have_content "Create new JIRA source"
  end

end
