require 'spec_helper'

feature "Home Page" do

  it "should be successful" do
    visit root_path
    find_link("Sign In").should be_visible
    find_link("Sign Up").should be_visible
    find_link("Join now").should be_visible
  end
  
  it "should have link to sign up page" do
    visit root_path
    find_link("Sign Up").click
    page.current_path.should eq new_account_registration_path
  end

  it "should have link to login page" do
    visit root_path
    find_link("Sign In").click
    page.current_path.should eq new_account_session_path
  end

end
