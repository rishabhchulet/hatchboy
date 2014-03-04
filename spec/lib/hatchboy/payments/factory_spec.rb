require 'spec_helper'

describe Hatchboy::Payments::Factory do
  let(:payment) { create :payment }

  context "when wrong type" do
    subject { described_class.get('foobar') }
    it "should raise error" do
      expect{ subject }.to raise_error(ActionController::RoutingError, 'Not Found')
    end
  end

  context "when type paypal" do
    subject { described_class.get('paypal') }
    it "should return instance of paypal" do
      expect(subject).to be_a Hatchboy::Payments::Paypal
    end
  end

  context "when type dwolla" do
    subject { described_class.get('dwolla') }
    it "should return instance of dwolla"
  end

end
