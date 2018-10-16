require 'spec_helper'

describe PublicActivity::Activity do
  subject { described_class.create key: 'foo.bar' }

  it "should send notification after creating any activity" do
    expect(Hatchboy::Notifications::Factory).to receive(:get)
    subject
  end
end
