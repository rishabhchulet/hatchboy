require "spec_helper"

feature "TeamsController#index" do

  background do
    @user = create :user
    @session = sign_in! @user.account
    @teams = create_list :team, 4, company: @user.company
    @teams.first.update_attribute(:created_at, 10.minutes.ago)
    @teams.second.update_attribute(:created_at, 7.minutes.ago)
    @teams.third.update_attribute(:created_at, 4.minutes.ago)
    @teams.fourth.update_attribute(:created_at, 2.minutes.ago)
    @session.visit teams_path
  end

  let(:page) { @session }

  let(:collection) { @teams }

  it_should_behave_like "teams list"

end
