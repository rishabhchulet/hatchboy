require 'spec_helper'

describe Hatchboy::Notifications::WorkLogs do
  let(:company) { create :company, created_by: create(:user, :with_subscription, role: 'CEO') do |c|
    c.users << c.created_by
  end }
  let(:team) { create(:team, company: company, created_by: company.created_by) }
  let(:log_user) { create(:user, :with_subscription, company: company, role: 'usual user') }
  let(:work_log) { create(:work_log, team: team, user: log_user) }
  let(:activity) do
    PublicActivity.with_tracking do
      PublicActivity::Activity.any_instance.stub(:email_notification).and_return true
      activity = work_log.create_activity key: "work_logs.#{action}", owner: company.created_by
      PublicActivity::Activity.any_instance.unstub(:email_notification)
      activity
    end
  end
  let(:action) { 'create' }
  let(:service) { described_class.new action, activity }

  describe "#new" do
    subject { service }
    context "when user added to team" do
      let(:action) { 'create' }
      it "should return right mailer method name" do
        expect(service.instance_variable_get(:@subscription_name)).to eq :time_log_added_to_team
      end
    end
  end

  describe "#recipients" do
    subject { service.recipients }

    context "user subscribed" do
      before do 
        @admin = create :user, :with_subscription, company: company, role: 'Manager'
        @admin_without_account = create :user_without_account, :with_subscription, company: company, role: 'Manager'
        @not_admin = create :user, :with_subscription, company: company, role: 'Foobar'
        @admin_without_subscription = create :user, :with_subscription, company: company, role: 'Manager' do |u|
          u.subscription.update time_log_added_to_team: false
        end
        @admin_unsubscribed_from_team = create :user, :with_subscription, company: company, role: 'Manager' do |u|
          create :unsubscribed_team, user: u, team: team
        end

        @user = create :user, :with_subscription, company: company, role: 'Foobar' do |u|
          team.users << u
        end
      end

      it "should return company admins and this user who create log" do
        expect(subject).to include company.created_by
        expect(subject).to include @admin
        expect(subject).to include log_user
        expect(subject).not_to include @admin_without_account
        expect(subject).not_to include @admin_without_subscription
        expect(subject).not_to include @admin_unsubscribed_from_team
        expect(subject).not_to include @not_admin
        expect(subject).not_to include @user
        expect(subject).to have(3).recipients
      end
    end
    context "user not subscribed" do
      before do 
        log_user.subscription.update(time_log_added_to_team: false)
      end

      it "should return company admins and this user who create log" do
        expect(subject).to include company.created_by
        expect(subject).to have(1).recipients
      end
    end  
  end

  describe "#deliver" do
    before { ActionMailer::Base.deliveries = [] }
    context "create team user notification" do
      let(:action) { 'create' }
      before do
        @admin = create :user, :with_subscription, company: company, role: 'Manager'
        service.deliver
      end
      it "should have links of action owner and action object" do
        NotificationsMailer.deliveries.each do |email|
          expect(email).to have_body_text(user_url(company.created_by)) # who
          expect(email).to have_body_text(team_url(team)) #where
          expect(email).to have_body_text(user_url(log_user)) # whom

          expect(email).to have_body_text(subscriptions_unsubscribe_url(from: :time_log_added_to_team))
          expect(email).to have_body_text(unsubscribed_teams_unsubscribe_url(team))
          expect(email).not_to have_body_text('translation_missing')
        end
      end
    end
  end  


end
