require 'spec_helper'

feature "Home Page" do

  it "should be successful" do
    visit root_path
    find_link("Login").should be_visible
    find_link("Sign up").should be_visible
    find_link("Join now").should be_visible
  end

end
