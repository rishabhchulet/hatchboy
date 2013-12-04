require "spec_helper"

feature "companies#edit" do
  
  background do
    @customer = create :customer
    @session = sign_in! @customer.account
    @company = @customer.company
    @session.visit edit_company_path
  end
  
  scenario "it should update company information" do
    screenshot @session
    @session.within "form#edit_company" do
      @session.fill_in "Name", with: @new_name = Faker::Company.name
      @session.fill_in "Description", with: @new_description = Faker::Company.name
    end
    @session.click_button "Save"
    @company.reload.name.should eq @new_name
    @company.reload.description.should eq @new_description
  end
  
  it "should validate company name" do
    @session.within "form#edit_company" do
      @session.fill_in "Name", with: ""
    end
    @session.click_button "Save"
    @session.find(:flash, :danger).should have_content "Name can't be blank"
  end
  
  it "should redirect on company view and show success message" do
    @session.within "form#edit_company" do
      @session.fill_in "Name", with: @new_name = Faker::Company.name
      @session.fill_in "Description", with: @new_description = Faker::Company.name
    end
    @session.click_button "Save"
    @session.current_path.should eq company_path
    @session.find(:flash, :success).should have_content "Information about your company has been successfully updated"
  end
  
end
