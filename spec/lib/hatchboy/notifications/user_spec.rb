require 'spec_helper'

describe Hatchboy::Notifications::User do
  let(:user) do
    create :user do |user|
      user.create_company attributes_for :company
    end  
  end
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
      let(:action) { 'delete' }
      it "should return right mailer method name" do
        expect(service.instance_variable_get(:@action)).to eq :user_deleted
      end
    end
    context "when team created" do
      let(:action) { 'create' }
      it "should return right mailer method name" do
        expect(service.instance_variable_get(:@action)).to eq :user_created
      end
    end
  end

  describe "#recipients" do
    before { @manager = create :user, company: user.company, role: 'Manager' }
    subject { service.recipients }
    it "should return CEO and company managers" do
      expect(subject).to have(2).recipients
      expect(subject).to include @manager
      expect(subject).to include user.company.created_by
    end
  end

end
