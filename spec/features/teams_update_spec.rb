require "spec_helper"

feature "teams#update" do

  background do
    @user = create :user
    @session = sign_in! @user.account
    @team = create :team, company: @user.company

    @session.visit edit_team_path(@team)

    @session.within("#edit_team") do
      @session.fill_in "Name", :with => "Changed team name"
    end
  end

  it "should update team name" do
    expect { @session.click_button "Save" }.to change{@team.reload.name}.to("Changed team name")
  end

  scenario "it should redirect to company page" do
    @session.click_button "Save"
    @session.current_path.should eq company_path
  end

end
