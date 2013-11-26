require "spec_helper"

feature "Confirm password" do

  background do
    @not_confirmed_user = FactoryGirl.create(:not_confirmed_user)
    @confirmed_user = FactoryGirl.create(:user)
  end

  context "with not confirmed user" do
    
    scenario "should change confirmed_at field on confirmation" do
      Devise.token_generator.stub(:digest).and_return(@not_confirmed_user.confirmation_token)
      expect{ visit user_confirmation_path(:confirmation_token => "valid_token") }.to change{ @not_confirmed_user.reload.confirmed_at }.from(nil)
    end

    scenario "should show successfull confirmation alert" do
      Devise.token_generator.stub(:digest).and_return(@not_confirmed_user.confirmation_token)
      visit user_confirmation_path(:confirmation_token => "valid_token")
      find(:flash, :success).should have_content "Your account was successfully confirmed."
    end

    scenario "should display form to resend confirmation instructions" do
      visit user_confirmation_path
      ActionMailer::Base.any_instance.should_receive(:mail) do |args|
        args[:template_name].should eq :confirmation_instructions 
        args[:to].should eq @not_confirmed_user.email
      end.once
      within "form#new_user" do
        fill_in "Email", :with => @not_confirmed_user.email
      end
      expect { click_button "Resend confirmation instructions" }.to change{ @not_confirmed_user.reload.confirmation_token }
    end

    scenario "should show successfull confirmation alert" do
      visit user_confirmation_path
      within "form#new_user" do
        fill_in "Email", :with => @not_confirmed_user.email
      end
      click_button "Resend confirmation instructions"
      find(:flash, :success).should have_content "You will receive an email with instructions about how to confirm your account in a few minutes."
    end
  end

  context "with confirmed user" do
    
    scenario "should display danger alert on attempt to resend instructions" do
      visit user_confirmation_path
      within "form#new_user" do
        fill_in "Email", :with => @confirmed_user.email
      end
      click_button "Resend confirmation instructions"
      find(:flash, :danger).should have_content "Email was already confirmed, please try signing in"
    end
  end
  
  context "with ivalid confirmation token" do
    
    scenario "should display danger alert" do
      visit user_confirmation_path :confirmation_token => "invalid_token"
      find(:flash, :danger).should have_content "Confirmation token is invalid"
    end
  end
end
