require "spec_helper"

feature "EmployeesController#create" do

  background do
    @customer = create :customer
    @session = sign_in! @customer.account
    @data = { name: Faker::Name.name, contact_email: Faker::Internet.email, role: generate(:role), status: generate(:status) }
    @session.visit new_employee_path 
  end

  scenario "create employee within company" do
    @session.within "#new_employee" do
      @session.fill_in "Name", with: @data[:name]
      @session.fill_in "Contact email", with: @data[:contact_email]
      @session.select @data[:role], :from => "Role"
      @session.select @data[:status], :from => "Status"
    end
    @session.click_button "Save"
    employee = @customer.company.employees.first
    employee.should_not be_blank
    employee.name.should eq @data[:name]
    employee.contact_email.should eq @data[:contact_email]
    employee.role.should eq @data[:role]
    employee.status.should eq @data[:status]
  end
  
  scenario "should redirect to company page" do
    @session.within "#new_employee" do
      @session.fill_in "Name", with: @data[:name]
      @session.fill_in "Contact email", with: @data[:contact_email]
      @session.select @data[:role], :from => "Role"
      @session.select @data[:status], :from => "Status"
    end
    @session.click_button "Save" 
    @session.current_path.should eq company_path
  end
  
  scenario "should show success message" do
    @session.within "#new_employee" do
      @session.fill_in "Name", with: @data[:name]
      @session.fill_in "Contact email", with: @data[:contact_email]
      @session.select @data[:role], :from => "Role"
      @session.select @data[:status], :from => "Status"
    end
    @session.click_button "Save"
    @session.find(:flash, :success).should have_content "New employee has been successfully added"
  end
  
  scenario "should validate name to be not empty" do
    @session.within "#new_employee" do
    @session.fill_in "Name", with: @data[:name]
      @session.fill_in "Contact email", with: "wrong@email"
    end
    @session.click_button "Save"
    @session.find(:flash, :danger).should_not be_blank
  end

end
