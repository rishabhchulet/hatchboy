require 'spec_helper'

describe Hatchboy::Notifications::Teams do
  let(:company) { create :company, created_by: create(:user, :with_subscription, role: 'CEO') do |c|
    c.users << c.created_by
  end }
  let(:team) { create :team, company: company, created_by: company.created_by }
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
      let(:action) { 'destroy' }
      it "should return right mailer method name" do
        expect(service.instance_variable_get(:@subscription_name)).to eq :team_was_removed
      end
    end
    context "when team created" do
      let(:action) { 'create' }
      it "should return right mailer method name" do
        expect(service.instance_variable_get(:@subscription_name)).to eq :team_was_added
      end
    end
  end

  describe "#recipients" do
    before { @manager = create :user, :with_subscription, company: team.company, role: 'Manager' }
    subject { service.recipients }
    it "should return CEO and company managers" do
      expect(subject).to have(2).recipients
      expect(subject).to include @manager
      expect(subject).to include team.created_by
    end
  end

end
