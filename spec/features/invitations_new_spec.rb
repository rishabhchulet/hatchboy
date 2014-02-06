require "spec_helper"

feature "customers_invitations#create" do

  background do
    @user = create :user
    @account = @user.account
    @session = sign_in! @account
    @session.visit new_user_invitation_path
  end

  context "with valid data" do
    background do
      @session.within "form#new_account" do
        @session.fill_in "Username", :with => @name = Faker::Name.name
        @session.fill_in "Email", :with => @email = Faker::Internet.email
      end
    end

    scenario "should create new user" do
      @session.click_button "Invite user"
      account = Account.where(email: @email).first
      account.should_not be_nil
      account.user.should_not be_nil
      account.user.company.should eq @user.company
      account.user.name.should eq @name
      account.should_not be_confirmed
    end

    scenario "should show success message" do
      @session.click_button "Invite user"
      @session.find(:flash, :success).should have_content "An invitation email has been sent"
    end

    scenario "should send confirmation email" do
      ActionMailer::Base.any_instance.should_receive(:mail) do |args|
        args[:template_name].should eq :invitation_instructions
        args[:to].should eq @email
      end.once
      @session.click_button "Invite user"
    end

  end

  scenario "should validate email" do
    @session.within "form#new_account" do
      @session.fill_in "Username", :with => @name = Faker::Name.name
    end
    @session.click_button "Invite user"
    @session.all("span.error").first.should_not be_blank
  end

  scenario "should validate email taken and confirmed" do
    @session.within "form#new_account" do
      @session.fill_in "Username", :with => @name = Faker::Name.name
      @session.fill_in "Email",    :with => @account.email
    end
    @session.click_button "Invite user"
    @session.all("span.error").first.should_not be_blank
  end

  scenario "should reinviite if email taken but not confirmed" do
    not_confirmed_account = create :not_confirmed_account, user: build(:user, company: @user.company)
    @session.within "form#new_account" do
      @session.fill_in "Username", :with => @name = Faker::Name.name
      @session.fill_in "Email",    :with => not_confirmed_account.email
    end
    @session.click_button "Invite user"
    @session.find(:flash, :success).should have_content "An invitation email has been sent"
  end

  scenario "should validate username presence" do
    @session.within "form#new_account" do
      @session.fill_in "Email",    :with => @email = Faker::Internet.email
    end
    @session.click_button "Invite user"
    @session.all("span.error").first.should_not be_blank
  end

end

