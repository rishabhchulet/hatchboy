require "spec_helper"

feature "sources#new" do
  
  background do
    @customer = create :customer
    @session = sign_in! @customer.account
    @session.visit new_source_path
  end

  scenario "it should show error if no connection to source" do
    @session.within("#new_jira_source") do
      @session.fill_in "Name", :with => "Jira source"
      @session.fill_in "Consumer key", :with => "jira_app"
      @session.fill_in "Url", :with => "http://example.com"
      @session.fill_in "Private key", :with => "invalid_private_key"
    end
    @session.click_button "Verify"
    @session.find(:flash, :danger).should have_content "Please review the problems below"
  end
  
  context "when connection to jira source established" do
    
    before do
      JiraSource.any_instance.stub(:connection).and_return(true)
      JiraSource.any_instance.stub_chain(:request_token, :authorize_url).and_return("http://authorize.me")
      JiraSource.any_instance.stub_chain(:request_token, :token).and_return("foo")
      JiraSource.any_instance.stub_chain(:request_token, :secret).and_return("bar")
      
      @session.within("#new_jira_source") do
        @session.fill_in "Name", :with => "Jira source"
        @session.fill_in "Consumer key", :with => "jira_app"
        @session.fill_in "Url", :with => "http://example.com"
        @session.fill_in "Private key", :with => "valid_private_key"
      end
      
      @session.click_button "Verify"
    end
    
    it "should create jira source" do
      jira_source = JiraSource.first
      jira_source.should_not be_blank
      jira_source.name.should eq "Jira source"
      jira_source.consumer_key.should eq "jira_app"
      jira_source.url.should eq "http://example.com"
      jira_source.private_key.should eq "valid_private_key"
    end
    
    scenario "it should redirect to verification page" do
      screenshot @session
      @session.current_url.should eq "http://authorize.me/"
    end
    
    scenario "it should store token, secret and source id in sessison" do
      jira_source_key = @session.get_rack_session_key('jira_source')
      jira_source_key[:id].should eq JiraSource.first.id
      jira_source_key[:request_token].should eq 'foo'
      jira_source_key[:request_token_secret].should eq 'bar'
    end
  end
    
end
