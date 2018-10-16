require "spec_helper"

describe Payment do

  specify do
    should be_kind_of Payment
    should respond_to :company
    should respond_to :created_by
    should respond_to :status
    should respond_to :description
    should respond_to :deleted
    should respond_to :recipients
    should respond_to :created_at
    should respond_to :updated_at
    should respond_to :transactions
  end

  specify do
    should validate_presence_of :company
    should validate_presence_of :created_by
  end

  describe "default values" do
    subject { create :payment }
    its(:status) { should eq described_class::STATUS_PREPARED }
  end

  context "#amount" do
    let(:payment) do 
      create(:payment) do |payment|
        create(:payment_recipient, amount: 10, payment: payment)
        create(:payment_recipient, amount: 10, payment: payment)
      end
    end

    subject { payment.amount}

    it "should be the sum of recipients amount" do
      should eq 20
    end
  end

end
