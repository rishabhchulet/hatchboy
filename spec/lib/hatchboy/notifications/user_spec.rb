require 'spec_helper'

describe Hatchboy::Notifications::Users do
  let(:user) { create :user, :with_subscription, role: 'CEO' }
  
  let(:activity) do
    user
    PublicActivity.with_tracking do
      user.create_activity key: 'user.create', owner: user.company.created_by
    end
  end

  let(:action) { 'create' }
  let(:service) { described_class.new action, activity }

  describe "#new" do
    subject { service }
    context "when team deleted" do
      let(:action) { 'destroy' }
      it "should return right mailer method name" do
        expect(service.instance_variable_get(:@subscription_name)).to eq :user_was_removed
      end
    end
    context "when team created" do
      let(:action) { 'create' }
      it "should return right mailer method name" do
        expect(service.instance_variable_get(:@subscription_name)).to eq :user_was_added
      end
    end
  end

  describe "#recipients" do
    before { @manager = create :user, :with_subscription, company: user.company, role: 'Manager' }
    subject { service.recipients }
    it "should return CEO and company managers" do
      expect(subject).to have(2).recipients
      expect(subject).to include @manager
      expect(subject).to include user.company.created_by
    end
  end

end
