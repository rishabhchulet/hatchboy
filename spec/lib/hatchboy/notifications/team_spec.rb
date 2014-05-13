require 'spec_helper'

describe Hatchboy::Notifications::Team do
  let(:team) { create :team }
  let(:activity) do
    team
    PublicActivity.with_tracking do
      team.create_activity key: 'team.create', owner: team.created_by
    end
  end
  let(:action) { 'create' }
  let(:service) { described_class.new action, activity }

  describe "#new" do
    subject { service }
    context "when team deleted" do
      let(:action) { 'delete' }
      it "should return right mailer method name" do
        expect(service.instance_variable_get(:@action)).to eq :team_deleted
      end
    end
    context "when team created" do
      let(:action) { 'create' }
      it "should return right mailer method name" do
        expect(service.instance_variable_get(:@action)).to eq :team_created
      end
    end
  end

  describe "#recipients" do
    before { @manager = create :user, company: team.company, role: 'Manager' }
    subject { service.recipients }
    it "should return CEO and company managers" do
      expect(subject).to have(2).recipients
      expect(subject).to include @manager
      expect(subject).to include team.created_by
    end
  end

end
