require "spec_helper"

feature "Sign up" do

  context "with valid data" do
    background do
      @data = { email: Faker::Internet.email, name: Faker::Name.name, password: generate(:password) }
      visit new_user_registration_path
      screenshot
      within "form#new_user" do
        fill_in "Email", :with => @data[:email]
        fill_in "Username", :with => @data[:name]
        fill_in "Password", :with => @data[:password]
        fill_in "Confirm Password", :with => @data[:password]
      end
      click_button "Sign up"
    end
    
    scenario "should create user" do
      User.where(email: @data[:email]).first.should_not be_blank 
    end
    
    scenario "should show success message" do
      find(:flash, :success).should have_content("A message with a confirmation link has been sent to your email address.")
    end
  
    scenario "should send email with instructions" do
    
    end
  
  end

  context "with invalid data" do
  
  end

end