require "spec_helper"

feature "UsersController#create" do

  background do
    @user = create :user, created_at: 20.minutes.ago
    @session = sign_in! @user.account
    @data = { name: Faker::Name.name, contact_email: Faker::Internet.email, role: generate(:role), status: generate(:status) }
    @session.visit new_user_path
  end

  scenario "create user within company" do
    @session.within "#new_user" do
      @session.fill_in "Name", with: @data[:name]
      @session.fill_in "Contact email", with: @data[:contact_email]
      @session.select @data[:role], :from => "Role"
      @session.select @data[:status], :from => "Status"
    end
    @session.click_button "Save"
    user = @user.company.users.last
    user.should_not be_blank
    user.name.should eq @data[:name]
    user.contact_email.should eq @data[:contact_email]
    user.role.should eq @data[:role]
    user.status.should eq @data[:status]
  end

  scenario "should redirect to company page" do
    @session.within "#new_user" do
      @session.fill_in "Name", with: @data[:name]
      @session.fill_in "Contact email", with: @data[:contact_email]
      @session.select @data[:role], :from => "Role"
      @session.select @data[:status], :from => "Status"
    end
    @session.click_button "Save"
    @session.current_path.should eq company_path
  end

  scenario "should show success message" do
    @session.within "#new_user" do
      @session.fill_in "Name", with: @data[:name]
      @session.fill_in "Contact email", with: @data[:contact_email]
      @session.select @data[:role], :from => "Role"
      @session.select @data[:status], :from => "Status"
    end
    @session.click_button "Save"
    @session.find(:flash, :success).should have_content "New user has been successfully added"
  end

  scenario "should validate name to be not empty" do
    @session.within "#new_user" do
    @session.fill_in "Name", with: @data[:name]
      @session.fill_in "Contact email", with: "wrong@email"
    end
    @session.click_button "Save"
    @session.find(:flash, :danger).should_not be_blank
  end

end

