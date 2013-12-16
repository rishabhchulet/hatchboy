require "spec_helper"

feature "EmployeesController#show" do

  background do
    @customer = create :customer
    @session = sign_in! @customer.account
    @employee = create :employee, company: @customer.company
  end
  
  scenario "should display information about employee" do
    @session.visit employee_path @employee
    @session.should have_content @employee.name
    @session.should have_content @employee.contact_email
    @session.should have_content @employee.role
    @session.should have_content @employee.status
  end
  
  scenario "should have link to edit employee page" do
    @session.visit employee_path @employee
    @session.click_link "Edit"
    @session.current_path.should eq edit_employee_path @employee
  end
  
  
end
