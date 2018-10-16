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
        @session.fill_in "Name", :with => @name = Faker::Name.name
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

  context "for existing user" do

    context "with contact email" do
      background do
        @inviting_user = create :user_without_account, company: @user.company
        @session.visit new_user_invitation_path(user_id: @inviting_user.id)
      end

      scenario "should name be disabled" do
        @session.should have_css('input#account_user_attributes_name[disabled]')
      end
      scenario "should email be disabled" do
        @session.should have_css('input#account_email[disabled]')
      end
      scenario "should form be filled by inviting user data" do
        @session.should have_css("input#account_user_attributes_name[value='#{@inviting_user.name}']")
        @session.should have_css("input#account_email[value='#{@inviting_user.contact_email}']")
      end
    end

    context "without contact email" do
      background do
        @inviting_user = create :user_without_account, contact_email: "", company: @user.company
        @session.visit new_user_invitation_path(user_id: @inviting_user.id)
      end

      scenario "should not email be disabled" do
        @session.should_not have_css('input#account_email[disabled]')
      end
      scenario "should save contact email from filled data" do
        @session.within "form#new_account" do
          @session.fill_in "Email", :with => @email = Faker::Internet.email
        end
        @session.click_button "Invite user"
        @inviting_user.reload.contact_email.should eq @email
      end
    end
  end

  scenario "should validate email" do
    @session.within "form#new_account" do
      @session.fill_in "Name", :with => @name = Faker::Name.name
    end
    @session.click_button "Invite user"
    @session.all("span.error").first.should_not be_blank
  end

  scenario "should validate email taken and confirmed" do
    @session.within "form#new_account" do
      @session.fill_in "Name", :with => @name = Faker::Name.name
      @session.fill_in "Email",    :with => @account.email
    end
    @session.click_button "Invite user"
    @session.all("span.error").first.should_not be_blank
  end

  scenario "should reinviite if email taken but not confirmed" do
    not_confirmed_account = create :not_confirmed_account, user: build(:user, company: @user.company)
    @session.within "form#new_account" do
      @session.fill_in "Name", :with => @name = Faker::Name.name
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