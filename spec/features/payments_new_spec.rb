require "spec_helper"

feature "payments#new" do

  given(:user) { create :user }
  given(:session) { sign_in! user.account }

  background do
    session.visit new_payment_path
  end

  scenario "it should have button to create payment"

  describe "When no errors" do
    scenario "should create payment"
    scenario "should redirect to payments list"
  end

  describe "When errors" do
    scenario "should show errors"
  end  

end
