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
    let(:ipn_params) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/paypal/ipn.json")) }
    subject { described_class.parse_ipn ipn_params }
    specify do
      expect(subject).to eq JSON.parse(File.read("#{Rails.root}/spec/fixtures/paypal/ipn_parsed.json"), :symbolize_names => true)
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
