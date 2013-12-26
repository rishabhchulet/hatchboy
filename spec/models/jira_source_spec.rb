require "spec_helper"

describe JiraSource do
  
  it { should be_kind_of Source }
  
  it "should validate connection to Jira REST API" do
    jira_source = described_class.create
    
  end
  
  
end
