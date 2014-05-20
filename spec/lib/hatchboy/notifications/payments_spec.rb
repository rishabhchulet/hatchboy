require 'spec_helper'

describe Hatchboy::Notifications::Payments do
  let(:company) { create :company, created_by: create(:user, :with_subscription, role: 'CEO') do |c|
    c.users << c.created_by
  end }
  let(:admin1) { create :user, :with_subscription, company: company, role: 'Manager' }
  let(:payment) { create :payment, company: company, created_by: company.created_by }
  let(:activity) do
    PublicActivity.with_tracking do
      PublicActivity::Activity.any_instance.stub(:email_notification).and_return true
      payment.stub(:status_was).and_return Payment::STATUS_PREPARED
      payment.stub(:status).and_return Payment::STATUS_SENT
      activity = payment.create_activity key: "payment.#{action}", owner: admin1, company: company
      PublicActivity::Activity.any_instance.unstub(:email_notification)
      activity
    end
  end
  let(:action) { 'update' }
  let(:service) { described_class.new action, activity }

  describe "#new" do
    subject { service }
    context "when payment sent" do
      it "should return right mailer method name" do
        expect(service.instance_variable_get(:@subscription_name)).to eq :payment_was_sent
      end
    end
  end

  describe "#recipients" do
    subject { service.recipients }

    context "when all users with subscription" do
      before do
        @recipient = create :payment_recipient, payment: payment, user: create(:user, :with_subscription, company: company, role: 'Foobar')
        @admin2 = create :user, :with_subscription, company: company, role: 'Manager'
        @not_admin = create :user, :with_subscription, company: company, role: 'Foobar'
      end

      it "should return company CEO, sender and recipients" do
        expect(subject).to include company.created_by
        expect(subject).to include admin1
        expect(subject).to include @recipient.user
        expect(subject).not_to include @admin2
        expect(subject).not_to include @not_admin
        expect(subject).to have(3).recipients
      end
    end  

    context "when recipients without subscription" do
      before do
        admin1.subscription.update payment_was_sent: false
        company.created_by.subscription.update payment_was_sent: false
        @recipient1 = create :payment_recipient, payment: payment, user: (create(:user, :with_subscription, company: company, role: 'Foobar') do |u|
          u.subscription.update payment_was_sent: false
        end)
        @recipient2 = create :payment_recipient, payment: payment, user: create(:user, :with_subscription, company: company, role: 'Foobar')
        @admin2 = create :user, company: company, role: 'Manager'
        @not_admin = create :user, company: company, role: 'Foobar'
      end

      it "should return only CEO and payment sender" do
        expect(subject).not_to include company.created_by
        expect(subject).not_to include admin1
        expect(subject).not_to include @recipient1.user
        expect(subject).not_to include @admin2
        expect(subject).not_to include @not_admin
        expect(subject).to include @recipient2.user
        expect(subject).to have(1).recipients
      end
    end    
  end

  describe "#deliver" do
    before do
      ActionMailer::Base.deliveries = []
      @recipient = create :payment_recipient, payment: payment, user: create(:user, :with_subscription, company: company, role: 'Foobar')
      service.deliver
    end
    it "should have links to sender and to payment" do
      Mailer.deliveries.each do |email|
        expect(email).to have_body_text(/#{user_url(admin1)}/) #who
        expect(email).to have_body_text(/#{payment_url(payment)}/) #what
      end
    end
  end

end
