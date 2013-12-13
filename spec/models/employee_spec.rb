require 'spec_helper'

describe Employee do
  
  it { should belong_to :company }
  
  it { should validate_presence_of :name}
  
  it "should validate email format" do
    employee = described_class.create(name: "foo")
    employee.should be_valid
    employee.contact_email = "wrond@email"
    employee.should_not be_valid
    employee.contact_email = "valid@email.com"
    employee.should be_valid
  end 
  
end
