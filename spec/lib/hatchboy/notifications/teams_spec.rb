require 'spec_helper'

describe Hatchboy::Notifications::Teams do
  let(:company) { create :company, created_by: create(:user, :with_subscription, role: 'CEO') do |c|
    c.users << c.created_by
  end }
  let(:team) { create :team, company: company, created_by: company.created_by }
  let(:activity) do
    PublicActivity.with_tracking do
      PublicActivity::Activity.any_instance.stub(:email_notification).and_return true
      activity = team.create_activity key: "team.#{action}", owner: team.created_by
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
        expect(service.instance_variable_get(:@subscription_name)).to eq :team_was_removed
      end
    end
    context "when team created" do
      let(:action) { 'create' }
      it "should return right mailer method name" do
        expect(service.instance_variable_get(:@subscription_name)).to eq :team_was_added
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

    context "when team created notification" do
      let(:action) { 'create' }
      before do
        @admin_without_subscription = create :user, :with_subscription, company: company, role: 'Manager' do |u|
          u.subscription.update team_was_added: false
        end
      end
      it "should return admins, subscribed to this notification" do
        expect(subject).to include @admin
        expect(subject).to include team.created_by
        expect(subject).not_to include @admin_without_subscription
        expect(subject).not_to include @not_admin
        expect(subject).to have(2).recipients
      end
    end

    context "when team deleted notification" do
      let(:action) { 'destroy' }
      before do
        @admin_unsubscribed_from_team = create :user, :with_subscription, company: company, role: 'Manager' do |u|
          create :unsubscribed_team, user: u, team: team
        end
        @admin_unsubscribed_from_another_team = create :user, :with_subscription, company: company, role: 'Manager' do |u|
          create :unsubscribed_team, user: u, team: create(:team, company: company, created_by: company.created_by)
        end
        @admin_without_subscription = create :user, :with_subscription, company: company, role: 'Manager' do |u|
          u.subscription.update team_was_removed: false
        end
      end
      it "should return admins, subscribed to this notification" do
        expect(subject).to include team.created_by
        expect(subject).to include @admin
        expect(subject).to include @admin_unsubscribed_from_another_team
        expect(subject).not_to include @admin_without_subscription
        expect(subject).not_to include @admin_unsubscribed_from_team
        expect(subject).not_to include @not_admin
        expect(subject).to have(3).recipients
      end
    end

  end
end
