require "spec_helper"

feature "company#show" do
  
  background do
    #Capybara.current_driver = :selenium
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
  
  scenario "Invite another customer link should be clickable" do
    @session.visit company_path
    @session.click_link "Invite another customer"
    @session.current_path.should eq new_customer_invitation_path
  end
  
  scenario "it should have link to edit company page" do
    @session.find("a.edit-company").click
    @session.current_path.should eq edit_company_path
  end
  
  context "when company has employees" do
  
    background do
      @employees = create_list :employee, 4, company: @customer.company
      @employees.first.update_attribute(:created_at, 10.minutes.ago) 
      @employees.second.update_attribute(:created_at, 7.minutes.ago)
      @employees.third.update_attribute(:created_at, 4.minutes.ago)
      @employees.fourth.update_attribute(:created_at, 2.minutes.ago)
      @session.visit company_path
    end
  
    scenario "it should contain information abount employees" do
      data_rows = @session.all("#employees_short_list .data-row")
      data_rows.count.should eq 4
      data_rows.first.should have_content @employees.first.name
      data_rows.first.should have_content @employees.first.contact_email
      data_rows.first.should have_content @employees.first.status
      data_rows.first.should have_content @employees.first.role
    end
    
    scenario "should have link to create employee page" do
      @session.click_link "Add another employee" 
      @session.current_path.should eq new_employee_path
    end
    
    scenario "should have link to view employee data" do
      data_row = @session.all("#employees_short_list .data-row")[1]
      data_row.hover
      data_row.find(".view-profile-action").click
      @session.current_path.should eq employee_path(@employees.second)
    end
    
    scenario "should have link to edit employee data" do
      data_row = @session.all("#employees_short_list .data-row")[1]
      data_row.hover
      data_row.find(".edit-profile-action").click
      @session.current_path.should eq edit_employee_path(@employees.second)
    end

    scenario "should have link to delete employee" do
      data_row = @session.all("#employees_short_list .data-row")[1]
      data_row.hover
      data_row.find(".list-row-action-delete-one").click
      popup_menu = @session.find(".list-row-action-popover-delete-one")
      popup_menu.should be_visible
      popup_menu.all("div", :text => "Cancel").first.should be_visible
      popup_menu.find(:xpath, ".//input[@value = 'Delete']").click
      Employee.exists?(@employees.second).should eq false
      @session.current_path.should eq company_path
    end
  end
  
end
