require "spec_helper"

feature "Restore password" do

  background do
    @user = FactoryGirl.create(:account)
  end

  context "while first step" do
    
    context "with valid data" do
      
      background do
        visit new_account_password_path
        within "form#new_account" do
          fill_in "Email", :with => @user.email
        end
      end
      
      scenario "should generate confirmation link" do
        expect { click_button "Send me reset password instructions" }.to change{ @user.reload.reset_password_token }
      end
      
      scenario "should show success alert" do
        click_button "Send me reset password instructions"
        find(:flash, :success).should have_content "You will receive an email with instructions about how to reset your password in a few minutes."
      end
  
      scenario "should send restore password instructions" do
        ActionMailer::Base.any_instance.should_receive(:mail) do |args|
          args[:template_name].should eq :reset_password_instructions
          args[:to].should eq @user.email
        end.once
        click_button "Send me reset password instructions"
      end
    end
    
    context "with invalid data" do
      
      scenario "should show warning alert" do
        visit new_account_password_path
        within "form#new_account" do
          fill_in "Email", :with => "wrong@email.com"
        end
        click_button "Send me reset password instructions"
        find(:flash, :danger).should have_content "Email not found"
      end
    end
    
  end

  context "step two" do
    
    context "with valid token" do
      
      background do
        reset_password_token = @user.send_reset_password_instructions
        visit edit_account_password_path(:reset_password_token => reset_password_token)
        within "form#new_account" do
          fill_in "Password", :with => "new_password"
          fill_in "Confirm Password", :with => "new_password"
        end
      end
      
      scenario "should update password" do
        expect { click_button "Change my password" }.to change{ @user.reload.encrypted_password }
      end
      
      scenario "should show success message" do
        click_button "Change my password"
        find(:flash, :success).should have_content "Your password was changed successfully. You are now signed in."
        123
      end
    end
    
    context "with invalid token" do
      
      scenario "should show warning mesage" do
        visit edit_account_password_path(:reset_password_token => "invalid token")
        within "form#new_account" do
          fill_in "Password", :with => "new_password"
          fill_in "Confirm Password", :with => "new_password"
        end
        click_button "Change my password"
        find(:flash, :danger).should have_content "Reset password token is invalid"
      end
    end
    
  end
end
