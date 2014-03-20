require 'spec_helper'

describe Hatchboy::Payments::Paypal do

  before do
    transfer_result = double({params: {correlation_id:'123'}, success?: true, test?: true}) 
    balance_result = double(success?: true)
    ActiveMerchant::Billing::PaypalGateway.any_instance.stub(:transfer).and_return(transfer_result)
    ActiveMerchant::Billing::PaypalGateway.any_instance.stub(:balance).and_return(balance_result)
  end
  let(:params) { {login: 'foo', password: 'bar', signature: 'foobar'} }
  let(:service) { described_class.new(params) }
  let(:ipn_params) {}

  describe "#new" do
    subject { service }
    it "should configutrate Paypal" do
      expect(subject.api.options[:login]).to eq 'foo'
      expect(subject.api.options[:password]).to eq 'bar'
      expect(subject.api.options[:signature]).to eq 'foobar'
    end
  end

  describe "#valid?" do
    subject { service.valid? }

    it { should eq true }
  end  

  describe "#parse_ipn && #parse_ipn_receivers" do
    let(:ipn_params) { {"payer_id"=>"8QY54YW733AVC92",
     "payment_date"=>"03:15:56 Mar 12, 2014 PDT",
     "payment_gross_1"=>"2.00",
     "payment_gross_2"=>"3.00",
     "payment_gross_3"=>"4.00",
     "payment_status"=>"Completed",
     "receiver_email_1"=>"test@test.com",
     "receiver_email_2"=>"samtester@yandex.ua",
     "charset"=>"windows-1252",
     "receiver_email_3"=>"vasiateste@hotmail.com",
     "mc_currency_1"=>"USD",
     "masspay_txn_id_1"=>"",
     "mc_currency_2"=>"USD",
     "masspay_txn_id_2"=>"41F19638AY4375728",
     "mc_currency_3"=>"USD",
     "masspay_txn_id_3"=>"9GT4944682186513F",
     "first_name"=>"test business account",
     "unique_id_1"=>"7",
     "notify_version"=>"3.7",
     "unique_id_2"=>"8",
     "unique_id_3"=>"9",
     "payer_status"=>"verified",
     "verify_sign"=>"ADolgIxsxnGzP1K-EPyvochdMlNKAQpguNr9M68YlMGXSAjt4ypomBjv",
     "payer_email"=>"test@test.com",
     "payer_business_name"=>"test business account  test's Test Store",
     "last_name"=>"test",
     "reason_code_1"=>"3004",
     "status_1"=>"Failed",
     "status_2"=>"Completed",
     "status_3"=>"Completed",
     "txn_type"=>"masspay",
     "mc_gross_1"=>"2.00",
     "mc_gross_2"=>"3.00",
     "mc_gross_3"=>"4.00",
     "payment_fee_1"=>"0.00",
     "residence_country"=>"US",
     "test_ipn"=>"1",
     "payment_fee_2"=>"0.06",
     "payment_fee_3"=>"0.08",
     "mc_fee_1"=>"0.00",
     "mc_fee_2"=>"0.06",
     "mc_fee_3"=>"0.08",
     "ipn_track_id"=>"1494e7ffd437b",
    } }
    subject { described_class.parse_ipn ipn_params }

    specify do
      expect(subject).to eq ({
        transaction: {
          type: "Mass Payment",
          ipn_track_id: "1494e7ffd437b",
          test_ipn: true
        },
        payment: {
          payment_date: "03:15:56 Mar 12, 2014 PDT",
          payment_status: "Completed",
          payment_amount: 9.0,
          fee_amount: 0.14,
          total_amount: 9.14,
          completed_amount: 7.0,
          unclaimed_amount: 0.0,
          returned_amount: 0.0,
          denied_amount: 2.0,
          pending_amount: 0.0,
          blocked_amount: 0.0
        },
        payer: {
          name: "test business account test",
          business_name: "test business account  test's Test Store",
          email: "test@test.com",
          country: "US",
          status: "verified",
          payer_id: "8QY54YW733AVC92"
        },
        receivers: [
          {
            status: "Failed",
            error_code: "3004",
            email: "test@test.com",
            amount: 2.0,
            currency: "USD",
            fee: 0.0,
            transaction_id: ''
          }, {
            status: "Completed",
            error_code: "",
            email: "samtester@yandex.ua",
            amount: 3.0,
            currency: "USD",
            fee: 0.06,
            transaction_id: '41F19638AY4375728'
          }, {
            status: "Completed",
            error_code: "",
            email: "vasiateste@hotmail.com",
            amount: 4.0,
            currency: "USD",
            fee: 0.08,
            transaction_id: '9GT4944682186513F'
          }
        ]
      })
    end

    describe "#get_sum" do
      let (:receivers) { [
        {amount:1, status: "Pending"},
        {amount:2, status: 'Blocked'},
        {amount:3, status: 'Denied'}
      ] }

      context "without status" do
        subject { described_class.get_sum(:amount, receivers) }

        it "should find sum" do
          expect(subject).to eq 6.0
        end
      end
      
      context "with status as string" do
        subject { described_class.get_sum(:amount, receivers, 'Pending') }

        it "should find sum" do
          expect(subject).to eq 1.0
        end
      end

      context "with status as array" do
        subject { described_class.get_sum(:amount, receivers, ['Denied', 'Blocked']) }

        it "should find sum" do
          expect(subject).to eq 5.0
        end
      end
    end

  end  
end
