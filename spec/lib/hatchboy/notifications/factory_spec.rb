require 'spec_helper'

describe Hatchboy::Notifications::Factory do
  let(:team) { create :team, created_by: (create :user, role: 'Manager') }
  let(:activity) do
    team
    PublicActivity.with_tracking do
      team.create_activity key: 'team.create', owner: team.created_by
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
        expect(subject).to be_a Hatchboy::Notifications::Team
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
    let(:notification) { described_class.get(activity) }
    subject { notification.deliver }
    it "should deliver the message" do
      expect{subject}.to change{::Mailer.deliveries.count}
    end
  end

end
