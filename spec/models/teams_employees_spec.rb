require 'spec_helper'

describe TeamsEmployees do
  
  it { should belong_to :team }
  it { should belong_to :employee }
  
  context "when companies are equel" do
    
    before do
      described_class.any_instance.stub(:companies_equality).and_return(true)
    end
    
    it { should validate_presence_of :team }
    it { should validate_presence_of :employee }
  end
  
  it "should validate team and employee equality" do
    team_employee = described_class.new
    team_employee.should_receive(:companies_equality).once
    team_employee.save
  end
end
