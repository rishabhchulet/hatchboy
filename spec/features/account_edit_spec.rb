require "spec_helper"
require 'carrierwave/test/matchers'

feature "account#edit" do
  include CarrierWave::Test::Matchers

  background do
    @user = create :user
    @session = sign_in! @user.account
    @company = @user.company
    @session.visit edit_account_registration_path
  end

  context "when name bing changed" do

    background do
      @session.within "form#edit_account" do
        @session.fill_in "Name", with: @new_name = Faker::Name.name
        @session.fill_in "Current password", with: @user.account.password
      end
    end

    scenario "it should update username" do
      expect {@session.click_button "Save"}.to change{@user.reload.name}.to(@new_name)
    end

    scenario "it should redirect to account view page" do
      @session.click_button "Save"
      @session.current_path.should eq account_path
    end

    scenario "it should show success message" do
      @session.click_button "Save"
      @session.find(:flash, :success).should have_content "You updated your account successfully."
    end
  end

  context "when email being updated" do

    background do
      @session.within "form#edit_account" do
        @session.fill_in "Email", with: @new_email = Faker::Internet.email
        @session.fill_in "Current password", with: @user.account.password
      end
    end

    scenario "it should save email in separate field" do
      expect { @session.click_button "Save" }.to change{ @user.account.reload.unconfirmed_email }.to(@new_email)
    end

    scenario "it should not update existing email" do
      expect { @session.click_button "Save" }.not_to change{ @user.account.reload.email }.to(@new_email)
    end

    scenario "it should send notification" do
      ActionMailer::Base.any_instance.should_receive(:mail) do |args|
        args[:template_name].should eq :confirmation_instructions
        args[:to].should eq @user.account.reload.unconfirmed_email
      end.once
      @session.click_button "Save"
    end

    scenario "it should show notification with instructions" do
      @session.click_button "Save"
      @session.find(:flash, :success).should have_content "Please check your email and click on the confirm link to finalize confirming your new email address"
    end

  end

  it "should update password" do
    @session.within "form#edit_account" do
      @session.fill_in "Password", with: "new_password"
      @session.fill_in "Password confirmation", with: "new_password"
      @session.fill_in "Current password", with: @user.account.password
    end
    @session.click_button "Save"
    @user.account.reload.valid_password?('new_password').should eq true
  end

  scenario "it should not save anything without current password" do
    @session.within "form#edit_account" do
      @session.fill_in "Name", with: @new_name = Faker::Name.name
    end
    @session.click_button "Save"
    @session.find(:flash, :danger).should_not be nil
  end

  scenario "should change avatar" do
    @session.within "form#edit_account" do
      @session.fill_in "Current password", with: @user.account.password
    end
    @session.execute_script('$("#upload-avatar .btn-file").removeClass("btn-file")')
    @session.attach_file('Avatar', Rails.root.to_s + "/spec/fixtures/images/test.png")
    @session.click_button "Save"
    @session.find(:flash, :success).should have_content "You updated your account successfully."
  end

  scenario "should create avatar images" do
    @user.avatar.class.enable_processing = true
    @session.within "form#edit_account" do
      @session.fill_in "Current password", with: @user.account.password
    end
    @session.execute_script('$("#upload-avatar .btn-file").removeClass("btn-file")')
    @session.attach_file('Avatar', Rails.root.to_s + "/spec/fixtures/images/test.png")
    expect { @session.click_button "Save"}.to change{ @user.reload.avatar.url }
    @user.avatar.should be_no_larger_than(200, 200)
    @user.avatar.thumb.should have_dimensions(50, 50)
  end

  scenario "should remove avatar" do
    @user.avatar.enable_processing = true
    @user.avatar = File.open(Rails.root.to_s + "/spec/fixtures/images/test.png", "rb")
    @user.save
    file_path = @user.avatar.file.path
    @session.visit edit_account_registration_path
    @session.within "form#edit_account" do
      @session.fill_in "Current password", with: @user.account.password
    end
    @session.find(:css, "a", :text => "Remove").click
    @session.click_button "Save"
    File.exists?(file_path).should eq false
    @user.avatar.file.should be_blank
  end

end
