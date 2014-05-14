require 'spec_helper'

describe Hatchboy::Notifications::Sources do
  let(:company) { create :company, created_by: create(:user, :with_subscription, role: 'CEO') do |c|
    c.users << c.created_by
  end }
  let(:source) { create :authorized_jira_source, company: company }
  let(:activity) do
    source
    PublicActivity.with_tracking do
      source.create_activity key: 'source.create', owner: company.created_by
    end
  end
  let(:action) { 'create' }
  let(:service) { described_class.new action, activity }

  describe "#new" do
    subject { service }
    context "when source created" do
      let(:action) { 'create' }
      it "should return right mailer method name" do
        expect(service.instance_variable_get(:@subscription_name)).to eq :data_source_was_created
      end
    end
  end

  describe "#recipients" do
    before { @manager = create :user, :with_subscription, company: source.company, role: 'Manager' }
    subject { service.recipients }
    it "should return CEO and company managers" do
      expect(subject).to have(2).recipients
      expect(subject).to include @manager
      expect(subject).to include source.company.created_by
    end
  end

end
