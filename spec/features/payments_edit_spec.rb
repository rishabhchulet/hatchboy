require "spec_helper"

feature "payments#edit" do

  given(:user) { create :user }
  given(:session) { sign_in! user.account }

  background do
    @payment = create :payment, status: Payment::STATUS_PREPARED, company: user.company, recipients_count: 3
    session.visit edit_payment_path(@payment)
  end

  scenario "it should have button to update payment"

  describe "When no errors" do
    scenario "should update payment"
    scenario "should redirect to payments list"
  end

  describe "When errors" do
    scenario "should show errors"
  end  

end
