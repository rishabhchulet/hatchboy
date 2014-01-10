require "spec_helper"

feature "work_log#new" do
  
  before do
    @customer = create :customer
    @session = sign_in! @customer.account
    @team = create :team, company: @customer.company
    @employee = create :employee, company: @customer.company 
    @session.visit new_team_work_log_path(@team)
  end
  
  context "with valid data" do

    before "should create new worklog" do
      @session.within "#new_work_log" do
        @session.select @employee.name , from: "Employee"
        @session.fill_in "Issue", :with => @desc = Faker::Lorem.sentence
        @session.find("#work_log_on_date_1i").select(2013)
        @session.find("#work_log_on_date_2i").select("December")
        @session.find("#work_log_on_date_3i").select(24)
        @session.fill_in "Time", :with => "10000"
        @session.fill_in "Comment", :with => @comment = Faker::Lorem.sentence
      end
      @session.click_button "Save"
    end
    
    it "should create new work log" do
      WorkLog.count.should eq 1 
    end
    
    it "should have valid work log field values" do
      work_log = WorkLog.first
      work_log.employee.should eq @employee
      work_log.issue.should eq @desc
      work_log.on_date.should eq Date.parse("2013-12-24")
      work_log.time.should eq 10000
      work_log.comment.should eq @comment
    end
    
    it "should redirect to team view page" do
      @session.current_path.should eq team_path(@team)
    end
    
    it "should show success message" do
      @session.find(:flash, :success).should have_content "New work time logged"
    end
    
  end
  
  it "should show error when data are not valid" do
    @session.click_button "Save"
    @session.find(:flash, :danger).should have_content "Please review the problems below:"
  end
  
end
