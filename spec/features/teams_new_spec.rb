require "spec_helper"

feature "teams#new" do
  
  before do
    @customer = create :customer
    @session = sign_in! @customer.account
    @company = @customer.company
    @session.visit new_team_path
  end
  

  context "with valid data" do

    before "should create new team" do
      @session.within "#new_team" do
        @session.fill_in "Name", :with => @name = Faker::Company.name
        @session.fill_in "Description", :with => @desc = Faker::Lorem.sentence
      end
      @session.click_button "Save"
    end
    
    it "should create new team" do
      Team.count.should eq 1  
      Team.first.name.should eq @name
      Team.first.description.should eq @desc
    end
    
    it "should redirect to company view page" do
      @session.current_path.should eq company_path
    end
    
    it "should show success message" do
      @session.find(:flash, :success).should have_content "New team has been successfully added"
    end
    
  end
  
  it "should show error when data are not valid" do
    @session.click_button "Save"
    @session.find(:flash, :danger).should have_content "Please review the problems below:"
  end
  
end
