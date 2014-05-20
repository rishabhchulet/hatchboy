require 'spec_helper'

describe Hatchboy::Notifications::DocuTemplates do
  
  let(:company) { create :company, created_by: create(:user, :with_subscription, role: 'CEO') do |c|
    c.users << c.created_by
  end }
  let(:docu_template) do 
    create :docu_template, company: company, user: company.created_by do |dt|
      dt.docu_sign_users.each { |user| user.create_subscription }
    end  
  end
  let(:creator) { docu_template.user }
  let(:signer) { docu_template.docu_sign_users.first }

  let(:activity) do
    PublicActivity.with_tracking do
      PublicActivity::Activity.any_instance.stub(:email_notification).and_return true
      activity = docu_template.create_activity key: "docu_template.#{action}", owner: company.created_by
      PublicActivity::Activity.any_instance.unstub(:email_notification)
      activity
    end
  end
  let(:action) { 'create' }
  let(:service) { described_class.new action, activity }

  describe "#new" do
    subject { service }
    context "when docu_template created" do
      let(:action) { 'create' }
      it "should return right mailer method name" do
        expect(service.instance_variable_get(:@subscription_name)).to eq :document_for_signing_was_uploaded
      end
    end
  end

  describe "#recipients" do
    subject { service.recipients }

    context "creator and signer subscribed" do
      before do
        @admin = create :user, :with_subscription, company: company, role: 'Manager'
        @admin_without_account = create :user_without_account, :with_subscription, company: company, role: 'Manager'
        @not_admin = create :user, :with_subscription, company: company, role: 'Foobar'
        @admin_without_subscription = create :user, :with_subscription, company: company, role: 'Manager' do |u|
          u.subscription.update document_for_signing_was_uploaded: false
        end
      end

      it "should return company admins, creator and signed user" do
        expect(subject).to include creator
        expect(subject).to include signer
        expect(subject).to include @admin
        expect(subject).not_to include @admin_without_account
        expect(subject).not_to include @admin_without_subscription
        expect(subject).to have(3).recipients
      end
    end
    context "nobody subscribed" do
      before do 
        @admin = create :user, company: company, role: 'Manager'
        signer.subscription.update(document_for_signing_was_uploaded: false)
        creator.subscription.update(document_for_signing_was_uploaded: false)
      end

      it "should return empty result" do
        expect(subject).not_to include @admin
        expect(subject).not_to include signer
        expect(subject).not_to include creator
        expect(subject).to eq []
      end
    end  
  end

  describe "#deliver" do
    before { ActionMailer::Base.deliveries = [] }
    context "create document for signing notification" do
      let(:action) { 'create' }
      before do
        @admin = create :user, :with_subscription, company: company, role: 'Manager'
        service.deliver
      end
      it "should have links of action owner and action object" do
        Mailer.deliveries.each do |email|
          expect(email).to have_body_text(/#{user_url(creator)}/) # who
          expect(email).to have_body_text(/#{docu_template_url(docu_template)}/) #what
          expect(email).to have_body_text(/#{docu_template.title}/)
        end
      end
    end
  end  


end
