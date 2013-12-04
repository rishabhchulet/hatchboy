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
  
  
end
