require 'spec_helper'

describe Subscription do
  it { should belong_to :user }
  it { should validate_presence_of(:user) }

  describe "#create" do
    subject { create(:user).create_subscription user_was_removed: false }
    it "should set default values" do
      expect(subject.user_was_added).to eq true
      expect(subject.user_was_removed).to eq false
    end
  end
end
