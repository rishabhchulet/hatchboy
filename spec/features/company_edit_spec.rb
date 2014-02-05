require "spec_helper"

feature "companies#edit" do

  background do
    @user = create :user
    @another_customer = create :user, company: @user.company
    @session = sign_in! @user.account
    @company = @user.company
    @session.visit edit_company_path
  end

  scenario "it should update company information" do
    @session.within "form#edit_company" do
      @session.fill_in "Name", with: @new_name = Faker::Company.name
      @session.fill_in "Description", with: @new_description = Faker::Lorem.paragraph
      @session.select @another_customer.name , from: "Contact person"
    end
    @session.click_button "Save"
    @company.reload.name.should eq @new_name
    @company.description.should eq @new_description
    @company.contact_person.should eq @another_customer
  end

  it "should validate company name" do
    @session.within "form#edit_company" do
      @session.fill_in "Name", with: ""
    end
    @session.click_button "Save"
    @session.find(:flash, :danger).should have_content "Please review the problems below"
  end

  it "should redirect on company view and show success message" do
    @session.within "form#edit_company" do
      @session.fill_in "Name", with: @new_name = Faker::Company.name
      @session.fill_in "Description", with: @new_description = Faker::Company.name
    end
    @session.click_button "Save"
    @session.current_path.should eq company_path
    @session.find(:flash, :success).should have_content "Information about your company has been successfully updated"
  end

  it "should have only company's, users in contact list option" do
    others_company_users = create_list :user, 3
    @session.visit edit_company_path
    @session.all("select#company_contact_person_id option").count.should eq 2
  end

end

