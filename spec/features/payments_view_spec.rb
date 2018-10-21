require "spec_helper"

feature "payments#view" do

  given(:user) { create :user }
  given(:session) { sign_in! user.account }

  background do
    @payment = create :payment, status: Payment::STATUS_PREPARED, company: user.company
    session.visit payment_path(@payment)
  end

  scenario "it should have a payment info listed"
  scenario "it should have a payment recipients info listed"
  scenario "it should have a payment transaction info listed"

  scenario "it should have a link to reload transaction info"
  

end
