require "spec_helper"

feature "sources#index" do

  background do
    @user = create :user
    @session = sign_in! @user.account
    @jira_source = create :authorized_jira_source, company: @user.company
    @session.visit sources_path
  end

  let(:page) { @session }

  let(:collection) { [@jira_source] }

  it_should_behave_like "sources list"

end
