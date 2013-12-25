require 'spec_helper'

describe Source do

  it { should belong_to :company }
  
  it "should validate presence of provider on create" do
    source = described_class.create
    source.should_not be_valid
    source.errors[:provider].should_not be_blank
  end
  
  it "should validate provider to be in list on create" do
    source = described_class.create provider: "unknown provider"
    source.should_not be_valid
    source.errors[:provider].should_not be_blank
  end
  
  it "should create source with specified provider" do
    source = described_class.create provider: :jira
    source.should be_valid
    source = described_class.find(source.id)
    source.should be_kind_of JiraSource
  end
  
end
