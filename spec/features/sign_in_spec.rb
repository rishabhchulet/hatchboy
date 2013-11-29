require 'spec_helper'

feature "Sing in" do

  context "with valid account data" do
  
    background :each do
      @user = FactoryGirl.create(:account)
      @session = sign_in! @user
    end
  
    scenario "should be successful" do
      @session.current_path.should eq root_path
      @session.find(:flash, :success).should have_content("Signed in successfully.")
    end
    
    scenario "should find the right user" do
      @session.visit account_path(:id => @user.id)
      expect(@session).to have_content @user.email
    end

  end
  
  context "with invalid data" do
    
    scenario "should show error alert" do
      visit new_account_session_path
        within("form") do
        fill_in "Email", with: ""
        fill_in "Password", with: "123456"
      end
      click_button "Sign in"
      find(:flash, :danger).should have_content("Invalid email or password. ")
    end
    
  end

end
