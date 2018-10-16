require 'spec_helper'

describe Hatchboy::Notifications::Sources do
  let(:company) { create :company, created_by: create(:user, :with_subscription, role: 'CEO') do |c|
    c.users << c.created_by
  end }
  let(:source) { create :authorized_jira_source, company: company }
  let(:activity) do
    PublicActivity.with_tracking do
      PublicActivity::Activity.any_instance.stub(:email_notification).and_return true
      activity = source.create_activity key: "source.#{action}", owner: company.created_by
      PublicActivity::Activity.any_instance.unstub(:email_notification)
      activity
    end
  end
  let(:action) { 'create' }
  let(:service) { described_class.new action, activity }

  describe "#new" do
    subject { service }
    context "when source created" do
      let(:action) { 'create' }
      it "should return right mailer method name" do
        expect(service.instance_variable_get(:@subscription_name)).to eq :data_source_was_created
      end
    end
  end

  describe "#recipients" do
    subject { service.recipients }

    before do
      @admin = create :user, :with_subscription, company: company, role: 'Manager'
      @admin_without_account = create :user_without_account, :with_subscription, company: company, role: 'Manager'
      @not_admin = create :user, :with_subscription, company: company, role: 'Foobar'
      @admin_without_subscription = create :user, :with_subscription, company: company, role: 'Manager' do |u|
        u.subscription.update data_source_was_created: false
      end
    end

    it "should return company admins" do
      expect(subject).to include company.created_by
      expect(subject).to include @admin
      expect(subject).not_to include @admin_without_account
      expect(subject).not_to include @admin_without_subscription
      expect(subject).not_to include @not_admin
      expect(subject).to have(2).recipients
    end
  end

  describe "#deliver" do
    before { ActionMailer::Base.deliveries = [] }

    context "create data source" do
      let(:action) { 'create' }
      before do
        @admin = create :user, :with_subscription, company: company, role: 'Manager'
        service.deliver
      end
      it "should have links to source and to owner" do
        NotificationsMailer.deliveries.each do |email|
          expect(email).to have_body_text(user_url(company.created_by))
          expect(email).to have_body_text(jira_source_url(source))

          expect(email).to have_body_text(subscriptions_unsubscribe_url(from: :data_source_was_created))
          expect(email).not_to have_body_text('translation_missing')
        end
      end
    end
  end

end
