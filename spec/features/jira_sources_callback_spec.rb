require "spec_helper"

feature "sources#new" do
  
  background do
    @customer = create :customer
    @session = sign_in! @customer.account
    @session.visit new_source_path
  end

  scenario "it should send to create new source if nothing stored in session" do
    @session.visit jira_callback_path
    @session.current_path.should eq new_source_path
  end

  scenario "it should show error if application was not allowed" do
    jira_source = create :authorized_jira_source
    @session.set_rack_session({:jira_source => {:id => jira_source.id, :request_token => "foo", :request_token_secret => "bar"}})
    @session.visit jira_callback_path
    @session.current_path.should eq edit_jira_source_path(jira_source)
    @session.find(:flash, :danger).should have_content "Jira connection validation failed"
  end
  
  scenario "it should try to authorize request token" do
    jira_source = create :authorized_jira_source
    @session.set_rack_session({:jira_source => {:id => jira_source.id, :request_token => "foo", :request_token_secret => "bar"}})
    JiraSource.any_instance.should_receive(:init_access_token!).with("abc123").and_return(true)
    @session.visit jira_callback_path(access_token: jira_source.access_token, oauth_verifier: "abc123")
    @session.current_path.should eq jira_source_path(jira_source)
    @session.find(:flash, :success).should have_content "Jira connection successfully verified"
  end

  scenario "it should show error if authorization failed" do
    jira_source = create :authorized_jira_source
    @session.set_rack_session({:jira_source => {:id => jira_source.id, :request_token => "foo", :request_token_secret => "bar"}})
    JiraSource.any_instance.should_receive(:init_access_token!).with("abc123").and_return(false)
    @session.visit jira_callback_path(access_token: jira_source.access_token, oauth_verifier: "abc123")
    @session.current_path.should eq edit_jira_source_path(jira_source)
    @session.find(:flash, :danger).should have_content "Jira connection validation failed"
  end

  scenario "it should not authorize of application denied" do
    jira_source = create :authorized_jira_source
    @session.set_rack_session({:jira_source => {:id => jira_source.id, :request_token => "foo", :request_token_secret => "bar"}})
    JiraSource.any_instance.should_not receive(:init_access_token!)
    @session.visit jira_callback_path(access_token: jira_source.access_token, oauth_verifier: "denied")
    @session.current_path.should eq edit_jira_source_path(jira_source)
    @session.find(:flash, :danger).should have_content "Jira connection validation failed"
  end
  
end
