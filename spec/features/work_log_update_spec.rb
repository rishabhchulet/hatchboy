require "spec_helper"

feature "work_log#update" do

  background do
    @user = create :user
    @session = sign_in! @user.account
    @team = create :team, company: @user.company

    @new_user = create :user, company: @user.company
    @work_log = create :work_log, team: @team, user: create(:user, company: @user.company)

    @session.visit edit_team_work_log_path(@team, @work_log)

    @session.within("#edit_work_log") do
      @session.select @new_user.name, from: "User"
      @session.fill_in "Comment", with: @desc = "Changed comment"
    end
  end

  it "should update worklog user" do
    expect { @session.click_button "Save" }.to change{@work_log.reload.user}.to(@new_user)
  end

  it "should update work log commnet" do
    expect { @session.click_button "Save" }.to change{@work_log.reload.comment}.to("Changed comment")
  end

  scenario "it should redirect to team page" do
    @session.click_button "Save"
    @session.current_path.should eq team_path(@team)
  end

end
