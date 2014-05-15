require 'spec_helper'

describe Hatchboy::Notifications::Users do
  let(:user) { create :user, :with_subscription, role: 'CEO' }
  let(:company) { user.company }
  let(:activity) do
    PublicActivity.with_tracking do
      PublicActivity::Activity.any_instance.stub(:email_notification).and_return true
      activity = user.create_activity key: "user.#{action}", owner: company.created_by
      PublicActivity::Activity.any_instance.unstub(:email_notification)
      activity
    end
  end

  let(:service) { described_class.new action, activity }

  describe "#new" do
    subject { service }
    context "when team deleted" do
      let(:action) { 'destroy' }
      it "should return right mailer method name" do
        expect(service.instance_variable_get(:@subscription_name)).to eq :user_was_removed
      end
    end
    context "when team created" do
      let(:action) { 'create' }
      it "should return right mailer method name" do
        expect(service.instance_variable_get(:@subscription_name)).to eq :user_was_added
      end
    end
  end

  describe "#recipients" do
    subject { service.recipients }

    before do
      @admin = create :user, :with_subscription, company: company, role: 'Manager'
      @admin_without_account = create :user_without_account, :with_subscription, company: company, role: 'Manager'
      @not_admin = create :user, :with_subscription, company: company, role: 'Foobar'
    end

    context 'on create notification' do
      let(:action) { 'create' }
      before do
        @admin_without_subscription = create :user, :with_subscription, company: company, role: 'Manager' do |u|
          u.subscription.update user_was_added: false
        end
      end
      it "should return subscribed admin" do
        expect(subject).to include company.created_by
        expect(subject).to include @admin
        expect(subject).not_to include @admin_without_account
        expect(subject).not_to include @admin_without_subscription
        expect(subject).not_to include @not_admin
        expect(subject).to have(2).recipients
      end
    end
    context 'on destroy notification' do
      let(:action) { 'destroy' }
      before do
        @admin_without_subscription = create :user, :with_subscription, company: company, role: 'Manager' do |u|
          u.subscription.update user_was_removed: false
        end
      end
      it "should return subscribed admin" do
        expect(subject).to include company.created_by
        expect(subject).to include @admin
        expect(subject).not_to include @admin_without_account
        expect(subject).not_to include @admin_without_subscription
        expect(subject).not_to include @not_admin
        expect(subject).to have(2).recipients
      end
    end
  end

end
