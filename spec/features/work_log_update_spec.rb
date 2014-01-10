require "spec_helper"

feature "work_log#update" do
  
  background do
    @customer = create :customer
    @session = sign_in! @customer.account
    @team = create :team, company: @customer.company
    
    @employee = create :employee, company: @customer.company 
    @work_log = create :work_log, team: @team, employee: create(:employee, company: @customer.company)

    @session.visit edit_team_work_log_path(@team, @work_log)
    
    @session.within("#edit_work_log") do
      @session.select @employee.name, from: "Employee" 
      @session.fill_in "Comment", with: @desc = "Changed comment"
    end
  end
    
  it "should update worklog employee" do
    expect { @session.click_button "Save" }.to change{@work_log.reload.employee}.to(@employee)
  end
  
  it "should update work log commnet" do
    expect { @session.click_button "Save" }.to change{@work_log.reload.comment}.to("Changed comment")
  end
    
  scenario "it should redirect to team page" do
    @session.click_button "Save"
    @session.current_path.should eq team_path(@team)
  end
  
end
