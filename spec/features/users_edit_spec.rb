require "spec_helper"

feature "UsersController#edit" do

  background do
    @user = create :user
    @session = sign_in! @user.account
    @new_user = create :user, company: @user.company
    @new_data = { name: Faker::Name.name, contact_email: Faker::Internet.email, role: generate(:role), status: generate(:status) }
    @session.visit edit_user_path @new_user
  end

  scenario "should update employee inforamtion" do
    @session.within "#edit_user" do
      @session.fill_in "Name", with: @new_data[:name]
      @session.fill_in "Contact email", with: @new_data[:contact_email]
      @session.select @new_data[:role], :from => "Role"
      @session.select @new_data[:status], :from => "Status"
    end
    @session.click_button "Save"
    @new_user.reload
    @new_user.name.should eq @new_data[:name]
    @new_user.contact_email.should eq @new_data[:contact_email]
    @new_user.role.should eq @new_data[:role]
    @new_user.status.should eq @new_data[:status]
  end

  scenario "should redirect to company page" do
    @session.click_button "Save"
    @session.current_path.should eq company_path
  end

  scenario "should show success message" do
    @session.click_button "Save"
    @session.find(:flash, :success).should have_content "Information about user has been successfully updated"
  end

  scenario "should validate name to be not empty" do
    @session.within "#edit_user" do
      @session.fill_in "Name", with: ""
    end
    @session.click_button "Save"
    @session.find(:flash, :danger).should_not be_blank
  end

end
