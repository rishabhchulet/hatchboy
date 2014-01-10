require "spec_helper"
require File.expand_path("lib/connectors/jira_connector")

describe Hatchboy::Connector::Jira do

  context "with class included descibed module" do

    before do
      class JiraConnectorTest
        include Hatchboy::Connector::Jira
        
        methods = {
          url: "http://example.com", consumer_key: "jira_consumer_key", private_key: "valid_private_key",
          access_token: "foo", access_token_secret: "bar"
        }
        
        methods.each do |method, result|
          self.send(:define_method, method) { result }
        end
        
        def update_attributes attributes
        end
      end
    end
  
    let(:resource) { JiraConnectorTest.new }
    
    it "should provide methods" do
      resource.should respond_to :request_token
      resource.should respond_to :set_request_token
      resource.should respond_to :set_access_token
      resource.should respond_to :init_access_token
      resource.should respond_to :init_access_token!
      resource.should respond_to :client
      resource.should respond_to :import!
    end
    
    it "client should be instance of JIRA::Client" do
      resource.client.should be_instance_of JIRA::Client
    end
    
    it "should set client settings depending on resource keys" do
      resource.client.consumer.key.should eq resource.consumer_key
      resource.client.consumer.uri.to_s.should eq resource.url
      key_file = resource.client.consumer.options[:private_key_file]
      file_content = File.open(key_file).read
      file_content.should eq resource.private_key
    end
    
    it "should store access_token and access_token_secret to database" do
      access_token = double(token: "foo", secret: "bar")
      request_token = OAuth::RequestToken.new(resource.client.consumer)
      resource.client.consumer.stub(:get_request_token => request_token)
      request_token.should_receive(:get_access_token).with(:oauth_verifier => 'abc123').and_return(access_token)
      resource.should_receive(:update_attributes).with({access_token: "foo", access_token_secret: "bar"})
      resource.init_access_token!('abc123')
    end
  
    it "should use access_token and access_token_secret to reconnect to source" do
      resource.connect_to_source
      resource.access_token.should eq resource.access_token
      resource.access_token_secret.should eq resource.access_token_secret
    end
  end
  
  context "with source model do" do
    
    let :source do
      #@see "/home/abezruchko/workData/projects/hatchboy/spec/fixtures/jira_mock_responses/" for values
      jira_source = create :authorized_jira_source
      stub_request(:get, jira_source.url + "/jira/rest/api/2/project").to_return(:status => 200, :body => get_mock_response("all_projects.get.json"))
      stub_request(:get, jira_source.url + "/jira/rest/api/2/project/10000").to_return(:status => 200, :body => get_mock_response("project.get.json"))
      stub_request(:get, jira_source.url + "/jira/rest/api/2/search?expand&fields=worklog,summary&jql=project='HAT'").
        to_return(:status => 200, :body => get_mock_response("project_issues.get.json"), :headers => {})
      jira_source
    end
    
    before do
      source.import!
    end
    
    it "should import projects as teams" do
      Team.count.should eq 1
      team = Team.first
      team.name.should eq "Hatchboy"
      team.description.should eq "Hello!"
      team.sources.should include source
    end
    
    it "should import time logs" do
      WorkLog.count.should eq 6
    end
    
    it "should set correct values for time log" do
      worklog = WorkLog.first
      worklog.source.should eq source
      worklog.team.should eq Team.first
      worklog.sources_user.should eq SourcesUser.first
      worklog.issue.should eq "Create employee pages"
      worklog.time.should eq 19800
      worklog.comment.should eq "That's just a begining"
      worklog.on_date.should eq Date.parse("2013-12-19")
    end
    
    it "should create unique source users" do
      SourcesUser.count.should eq 2
      SourcesUser.first.name.should eq "abezruchko"
      SourcesUser.first.email.should eq "abezruchko@shakuro.com"
    end
    
    it "should not import the same data twice" do
      source.import!
      Team.count.should eq 1
      SourcesUser.count.should eq 2
      WorkLog.count.should eq 6
    end
  end
 
end
