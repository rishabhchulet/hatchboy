require 'spec_helper'

describe TeamsUsers do

  it { should belong_to :team }
  it { should belong_to :user }

  context "when companies are equel" do

    before do
      described_class.any_instance.stub(:companies_equality).and_return(true)
    end

    it { should validate_presence_of :team }
    it { should validate_presence_of :user }
  end

  it "should validate team and employee equality" do
    team_user = described_class.new
    team_user.should_receive(:companies_equality).once
    team_user.save
  end
end

