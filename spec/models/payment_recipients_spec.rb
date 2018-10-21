require "spec_helper"

describe PaymentRecipient do

  specify do
    should be_kind_of PaymentRecipient
    should respond_to :payment
    should respond_to :user
    should respond_to :amount

    should validate_presence_of :user
    should validate_presence_of :amount
  end

  describe "custom validations" do
    subject(:recipient) { described_class.new }
    before { recipient.valid? }

    specify do
      expect(recipient.errors.to_a).to include "Amount can't be less or equal to zero"
      expect(recipient.errors.to_a).to include "User should login at least one time before you can pay him"
    end
  end

  describe "rounding amount" do
    subject { create :payment_recipient, amount: 1.33333333 }
    it "should round amount before save" do
      expect(subject.amount).to eq 1.33
    end
  end

  describe "validation of amount" do
    context "when 0" do
      subject { build :payment_recipient, amount: 0}
      it "should not be valid" do
        expect(subject.valid?).to eq false
        expect{ subject.save! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "when -1" do
      subject { build :payment_recipient, amount: -1}
      it "should not be valid" do
        expect(subject.valid?).to eq false
        expect{ subject.save! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "when 0.01" do
      subject { build :payment_recipient, amount: 0.01}
      it "should be valid" do
        expect(subject.valid?).to eq true
        expect{ subject.save }.not_to raise_error
      end
    end
  end

end
