require 'spec_helper'
require 'stripe_mock'

describe Hatchboy::Payments::Stripe do
  before { StripeMock.start }
  after { StripeMock.stop }

  let(:service) { described_class.new({}) }
  let(:payment) do
    create(:payment) do |payment|
      create(:payment_recipient, amount: 10, payment: payment)
      create(:payment_recipient, amount: 10, payment: payment)
    end
  end

  describe "#valid?" do
    subject { service.valid? }

    it { should eq true }
  end

  context "when saving recipient" do
    let(:user) { create :user }

    it "should create new recipient" do
      responce = service.save_recipient user.create_stripe_recipient
      responce.should_not be_false
      responce[:recipient_token].should_not be_empty
      responce[:last_4_digits].should_not be_empty
    end

    describe "when update recipient" do
      before do
        responce = service.save_recipient user.create_stripe_recipient
        user.stripe_recipient.update_attributes(responce)
      end

      # Need to implement new behavior for updating recipients
      # https://github.com/rebelidealist/stripe-ruby-mock/wiki/Implementing-a-New-Behavior

      #it "should not change recipient token" do
      #  responce = service.save_recipient user.stripe_recipient
      #  responce[:recipient_token].should eq user.stripe_recipient.recipient_token
      #end
    end
  end

  context "when paying" do
    
    context "when recipients with no stripe data" do
      it "should return error" do
        result = service.pay payment
        result[:success].should be_false
        result[:message].should include "did not set stripe data"
      end
    end
    
    context "when recipients with stripe data" do
      before do
        payment.recipients.each {|r| r.user.create_stripe_recipient}
      end

      # Need to implement new behavior for transfers and balance
      # https://github.com/rebelidealist/stripe-ruby-mock/wiki/Implementing-a-New-Behavior
      
      #it "should create transfers" do
      #  result = service.pay payment
      #  payment.recipients.reload.each{|r| r.stripe_transfer_id.should_not be_empty}
      #  result[:success].should be_true
      #end
    end
  end
end