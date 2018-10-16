require 'spec_helper'

describe DocuSign do
  it { should belong_to :company }
  it { should belong_to :user }
  
  it { should validate_presence_of(:company) }
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:document) }

  it "has STATUS_PROCESSING" do
   DocuSign::STATUS_PROCESSING.should == "processing"
  end

  it "has STATUS_SIGNED" do
   DocuSign::STATUS_SIGNED.should == "signed"
  end

  it "has STATUS_CANCELLED" do
   DocuSign::STATUS_CANCELLED.should == "cancelled"
  end
end
