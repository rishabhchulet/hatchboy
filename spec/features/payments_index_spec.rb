require "spec_helper"

feature "payments#index" do

  given(:user) { create :user }
  given(:session) { sign_in! user.account }

  background do
    @payment1 = create :payment, status: Payment::STATUS_PREPARED, company: user.company
    @payment2 = create :payment, status: Payment::STATUS_SENT, company: user.company
    @payment3 = create :payment, deleted: true, company: user.company
    session.visit payments_path
  end

  scenario "it should have all payments listed"
  scenario "it should contain link to new payment"
  scenario "it should contain links to view,edit,send and delete for prepared payments"
  scenario "it should contain links to view,edit and delete for sent payments"
  scenario "it should contain links to view for deleted payments"

end
