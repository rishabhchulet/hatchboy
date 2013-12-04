require "spec_helper"

feature "account#show" do
  
  background do
    @customer = create :customer
    @session = sign_in! @customer.account 
    @session.visit account_path
  end
  
  scenario "it should contain company name" do
    @session.should have_content @customer.company.name
  end
  
  scenario "it should contain customers' email" do
    @session.should have_content @customer.account.email
  end
  
  scenario "it should contain customers' name" do
    @session.should have_content @customer.name
  end
  
end
