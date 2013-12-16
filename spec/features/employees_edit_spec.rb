require "spec_helper"

feature "EmployeesController#edit" do

  background do
    @customer = create :customer
    @session = sign_in! @customer.account
    @employee = create :employee, company: @customer.company
    @new_data = { name: Faker::Name.name, contact_email: Faker::Internet.email, role: generate(:role), status: generate(:status) }
    @session.visit edit_employee_path @employee 
  end

  scenario "should update employee inforamtion" do
    @session.within "#edit_employee" do
      @session.fill_in "Name", with: @new_data[:name]
      @session.fill_in "Contact email", with: @new_data[:contact_email]
      @session.select @new_data[:role], :from => "Role"
      @session.select @new_data[:status], :from => "Status"
    end
    @session.click_button "Save"
    @employee.reload
    @employee.name.should eq @new_data[:name]
    @employee.contact_email.should eq @new_data[:contact_email]
    @employee.role.should eq @new_data[:role]
    @employee.status.should eq @new_data[:status]
  end
  
  scenario "should redirect to company page" do
    @session.click_button "Save" 
    @session.current_path.should eq company_path
  end
  
  scenario "should show success message" do
    @session.click_button "Save"
    @session.find(:flash, :success).should have_content "Information about employee has been successfully updated"
  end
  
  scenario "should validate name to be not empty" do
    @session.within "#edit_employee" do
      @session.fill_in "Name", with: ""
    end
    @session.click_button "Save"
    @session.find(:flash, :danger).should_not be_blank
  end

end
