require "spec_helper"

feature "company#show" do
  
  background do
    @customer = create :customer 
    @session = sign_in! @customer.account 
    @session.visit company_path
  end
  
  scenario "it should contain company name" do
    @session.should have_content @customer.company.name
  end
  
  scenario "it should contain company description" do
    @session.should have_content @customer.company.description
  end
  
  scenario "it should contain contact person name" do
    @session.should have_content @customer.name
  end
  
end
