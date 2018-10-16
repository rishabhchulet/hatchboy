require "spec_helper"

describe JiraSource do
  
  it { should be_kind_of Source }
  
  it { should respond_to :request_token }
  it { should respond_to :set_request_token }
  it { should respond_to :set_access_token }
  it { should respond_to :init_access_token }
  it { should respond_to :init_access_token! }
  it { should respond_to :client }
  it { should respond_to :import! }
  
  it { should validate_presence_of :url }
  it { should validate_presence_of :consumer_key }
  it { should validate_presence_of :private_key }
  
  its(:provider) { should eq :jira }
  
  it "should validate connection to jira on save" do
    source = described_class.new(:name => "Jira Source", :consumer_key => "some key", :url => "http://example.com/jira", :private_key => "long-long-key")
    source.should_receive(:connection).once
    source.save
  end
  
end
