require "spec_helper"

feature "Sign up" do

  background do
    @data = { email: Faker::Internet.email, name: Faker::Name.name, password: generate(:password), company_name: Faker::Name.name }
  end

  context "with valid data" do

    background do
      visit new_account_registration_path
      within "form#new_account" do
        fill_in "Email", :with => @data[:email]
        fill_in "Username", :with => @data[:name]
        fill_in "Password", :with => @data[:password]
        fill_in "Password confirmation", :with => @data[:password]
        fill_in "Company Name", :with => @data[:company_name]
      end
      click_button "Sign up"
    end

    scenario "should create user" do
      Account.where(email: @data[:email]).first.should_not be_blank
    end

    scenario "should create.user with name" do
      Account.where(email: @data[:email]).first.user.name.should eq @data[:name]
    end

    scenario "should create company with name" do
      Account.where(email: @data[:email]).first.user.company.name.should eq @data[:company_name]
    end

    scenario "should show success message" do
      find(:flash, :success).should have_content("A message with a confirmation link has been sent to your email address.")
    end

  end

  scenario "should send email with instructions" do

    ActionMailer::Base.any_instance.should_receive(:mail) do |args|
      args[:to].should eq @data[:email]
      args[:subject].should eq "Confirmation instructions"
      args[:template_name].should eq :confirmation_instructions
    end.once

    visit new_account_registration_path

    within "form#new_account" do
      fill_in "Email", :with => @data[:email]
      fill_in "Username", :with => @data[:name]
      fill_in "Password", :with => @data[:password]
      fill_in "Password confirmation", :with => @data[:password]
      fill_in "Company Name", :with => @data[:company_name]
    end
    click_button "Sign up"
  end

  context "with invalid data" do

    scenario "should show danger alert" do
      visit new_account_registration_path
      within "form#new_account" do
        fill_in "Username", :with => @data[:name]
        fill_in "Password", :with => @data[:password]
        fill_in "Password confirmation", :with => @data[:password]
      end
      click_button "Sign up"
      find(:flash, :danger).should_not be_blank
    end
  end

end
