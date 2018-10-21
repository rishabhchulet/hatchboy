require 'spec_helper'

describe Hatchboy::Notifications::PostReceivers do
  let(:company) { create :company, created_by: create(:user, :with_subscription, role: 'CEO') do |c|
    c.users << c.created_by
  end }
  let(:team) { create(:team, company: company, created_by: company.created_by) }
  let(:post_receiver) { create :post_receiver, post: create(:post, user: company.created_by), receiver: team }
  let(:activity) do
    PublicActivity.with_tracking do
      PublicActivity::Activity.any_instance.stub(:email_notification).and_return true
      activity = post_receiver.create_activity key: "post_receiver.#{action}", owner: company.created_by
      PublicActivity::Activity.any_instance.unstub(:email_notification)
      activity
    end
  end
  let(:action) { 'create' }
  let(:service) { described_class.new action, activity }

  describe "#new" do
    subject { service }
    context "when post added to team" do
      let(:action) { 'create' }
      it "should return right mailer method name" do
        expect(service.instance_variable_get(:@subscription_name)).to eq :post_added_to_team
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
        u.subscription.update post_added_to_team: false
      end
      @admin_unsubscribed_from_team = create :user, :with_subscription, company: company, role: 'Manager' do |u|
        create :unsubscribed_team, user: u, team: team
      end

      @user = create :user, :with_subscription, company: company, role: 'Foobar' do |u|
        team.users << u
      end
      @user_in_other_team = create :user, :with_subscription, company: company, role: 'Fuubar' do |u|
        team2 = create(:team, company: company, created_by: company.created_by)
        team2.users << u
      end
      @user_without_subscription = create :user, company: company, role: 'Foobar' do |u|
        team.users << u
      end
      @user_unsubscribed_from_team = create :user, :with_subscription, company: company, role: 'Manager' do |u|
        create :unsubscribed_team, user: u, team: team
      end
      @user_unsubscribed_from_other_team = create :user, :with_subscription, company: company, role: 'Manager' do |u|
        create :unsubscribed_team, user: u, team: create(:team, company: company, created_by: company.created_by)
      end
    end

    it "should return company admins and team users with subscription" do
      expect(subject).to include company.created_by
      expect(subject).to include @admin
      expect(subject).to include @user
      expect(subject).to include @user_unsubscribed_from_other_team
      expect(subject).not_to include @admin_without_account
      expect(subject).not_to include @admin_without_subscription
      expect(subject).not_to include @admin_unsubscribed_from_team
      expect(subject).not_to include @not_admin
      expect(subject).not_to include @user_in_other_team
      expect(subject).not_to include @user_without_subscription
      expect(subject).not_to include @user_unsubscribed_from_team
      expect(subject).to have(4).recipients
    end
  end

  describe "#deliver" do
    before { ActionMailer::Base.deliveries = [] }

    context "add post to team" do
      let(:action) { 'create' }
      before do
        @admin = create :user, :with_subscription, company: company, role: 'Manager'
        service.deliver
      end
      it "should have links to post, to owner and to team" do
        NotificationsMailer.deliveries.each do |email|
          expect(email).to have_body_text(user_url(company.created_by)) #who
          expect(email).to have_body_text(post_url(post_receiver.post)) #what
          expect(email).to have_body_text(team_url(post_receiver.receiver)) #where

          expect(email).to have_body_text(subscriptions_unsubscribe_url(from: :post_added_to_team))
          expect(email).to have_body_text(unsubscribed_teams_unsubscribe_url(post_receiver.receiver))
          expect(email).not_to have_body_text('translation_missing')
        end
      end
    end
  end

end
