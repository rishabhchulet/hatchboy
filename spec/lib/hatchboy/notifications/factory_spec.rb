require 'spec_helper'

describe Hatchboy::Notifications::Factory do
  let(:company) { create :company, created_by: create(:user, :with_subscription, role: 'CEO') do |c|
    c.users << c.created_by
  end }
  let(:team) { create :team, company: company, created_by: company.created_by }
  let(:action) { 'create' }
  let(:activity) do
    PublicActivity.with_tracking do
      PublicActivity::Activity.any_instance.stub(:email_notification).and_return true
      activity = team.create_activity key: "team.#{action}", owner: team.created_by
      PublicActivity::Activity.any_instance.unstub(:email_notification)
      activity
    end
  end

  describe "#new" do
    subject { described_class.new activity }

    it "should set default variables" do
      expect(subject.instance_variable_get(:@activity)).to eq activity
      expect(subject.instance_variable_get(:@company)).to eq activity.company
      expect(subject.instance_variable_get(:@object)).to eq team
      expect(subject.instance_variable_get(:@owner)).to eq team.created_by
    end
  end

  describe "#get" do
    context "when notification exists" do
      subject { described_class.get activity }
      it "should return instance of notification" do
        expect(subject).to be_a Hatchboy::Notifications::Teams
      end
    end

    context "when notification not exists" do
      subject { described_class.get activity.update(key: 'foo.bar') }
      it "should return nil" do
        expect(subject).to be_a NilClass
      end
    end
  end

  describe "#deliver" do
    before { @notification = described_class.get(activity) }
    subject { @notification.deliver }
    it "should deliver the message" do
      expect{subject}.to change{::Mailer.deliveries.count }.by 1
    end
  end

end
