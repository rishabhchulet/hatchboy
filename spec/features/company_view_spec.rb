require "spec_helper"

feature "company#show" do
  
  background do
    @customer = create :customer 
    @session = sign_in! @customer.account 
  end
  
  scenario "it should contain company name" do
    @session.visit company_path
    @session.should have_content @customer.company.name
  end
  
  scenario "it should contain company description" do
    @session.visit company_path
    @session.should have_content @customer.company.description
  end
  
  scenario "it should contain contact person name" do
    @session.visit company_path    
    @session.should have_content @customer.name
  end
  
  scenario "it should contain information abount customers" do
    members = create_list :customer, 2, company: @customer.company
    members.map { |m| m.account.update_attribute(:created_at, 7.minutes.ago) }
    not_confirmed_account = create :not_confirmed_account, created_at: 5.minutes.ago, profile: build(:customer, company: @customer.company)
    @customer.account.update_attribute(:created_at, 10.minutes.ago)
    @session.visit company_path 
    data_rows = @session.all("#customers_short_list .data-row")
    data_rows.count.should eq 4
    data_rows.first.should have_content "work"
    data_rows.first.should have_content @customer.name
    data_rows.first.should have_content @customer.account.email
    data_rows.last.should have_content "not confirmed"
    data_rows.last.should have_content not_confirmed_account.profile.name
    data_rows.last.should have_content not_confirmed_account.email
  end
  
  scenario "contact person should ne clickable" do
    @session.visit company_path
    @session.find("#contact-person-link").click
    @session.current_path.should eq customer_path(@customer)
  end
  
  scenario "customer's profile should be clickable" do
    @session.visit company_path
    first_account_row = @session.all("#customers_short_list .data-row").first
    first_account_row.hover
    first_account_row.find(".view-profile-action").click
    @session.current_path.should eq customer_path(@customer)
  end
end
