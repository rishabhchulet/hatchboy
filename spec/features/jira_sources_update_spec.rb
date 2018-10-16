require "spec_helper"

feature "sources#update" do

  background do
    @user = create :user
    @session = sign_in! @user.account
    @jira_source = create :authorized_jira_source
    @session.visit edit_jira_source_path(@jira_source)
  end

  scenario "it should show error if no connection to source" do
    @session.click_button "Verify"
    screenshot @session
    @session.find(:flash, :danger).should have_content "Please review the problems below"
  end

  context "when connection to jira source established" do

    before do
      JiraSource.any_instance.stub(:connection).and_return(true)
      JiraSource.any_instance.stub_chain(:request_token, :authorize_url).and_return("http://authorize.me")
      JiraSource.any_instance.stub_chain(:request_token, :token).and_return("foo")
      JiraSource.any_instance.stub_chain(:request_token, :secret).and_return("bar")

      @session.within("#edit_jira_source") do
        @session.fill_in "Name", :with => "Changed jura source name"
      end

    end

    it "should update jira source" do
      expect { @session.click_button "Verify" }.to change{@jira_source.reload.name}.to("Changed jura source name")
    end

    scenario "it should redirect to verification page" do
      @session.click_button "Verify"
      @session.current_url.should eq "http://authorize.me/"
    end

    scenario "it should store token, secret and source id in sessison" do
      @session.click_button "Verify"
      jira_source_key = @session.get_rack_session_key('jira_source')
      jira_source_key[:id].should eq JiraSource.first.id
      jira_source_key[:request_token].should eq 'foo'
      jira_source_key[:request_token_secret].should eq 'bar'
    end
  end

end
